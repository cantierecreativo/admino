require 'active_model/naming'
require 'active_model/translation'

require 'admino/query/dsl'

module Admino
  module Query
    class Base
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      extend Dsl

      attr_reader :params
      attr_reader :groups
      attr_reader :fields

      def self.i18n_scope
        :query
      end

      def initialize(params = nil, config = nil)
        @params = (params || {}).symbolize_keys!
        @config = config

        init_groups
        init_fields
      end

      def scope(starting_scope = nil)
        starting_scope ||= if config.starting_scope_callable
                             config.starting_scope_callable.call(self)
                           else
                             raise ArgumentError, 'no starting scope provided'
                           end

        scope_builder = starting_scope

        (fields + groups).each do |field|
          scope_builder = field.augment_scope(scope_builder)
        end

        if config.ending_scope_callable
          scope_builder.instance_exec(self, &config.ending_scope_callable)
        else
          scope_builder
        end
      end

      def persisted?
        false
      end

      def config
        @config || self.class.config
      end

      def groups
        @groups.values
      end

      def group_by_name(name)
        @groups[name]
      end

      def fields
        @fields.values
      end

      def field_by_name(name)
        @fields[name]
      end

      private

      def init_groups
        @groups = {}
        i18n_key = self.class.model_name.i18n_key
        config.groups.each do |config|
          @groups[config.name] = Group.new(config, params, i18n_key)
        end
      end

      def init_fields
        @fields = {}
        config.fields.each do |config|
          @fields[config.name] = Field.new(config, params)
        end
      end
    end
  end
end

