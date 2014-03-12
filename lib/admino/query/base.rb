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

      def initialize(params)
        @params = (params || {}).to_h.symbolize_keys!

        init_groups
        init_fields
      end

      def scope(starting_scope = nil)
        scope_builder = starting_scope || config.starting_scope.call(self)

        (fields + groups).each do |field|
          scope_builder = field.augment_scope(scope_builder)
        end

        scope_builder.instance_exec(self, &config.ending_scope)
      end

      def persisted?
        false
      end

      private

      def init_groups
        @groups = {}
        i18n_key = self.class.model_name.i18n_key
        config.groups.each do |config|
          @groups[config.name] = Group.new(config, params, i18n_key)
        end
      end

      def groups
        @groups.values
      end

      def group_by_name(name)
        @groups[name]
      end

      def init_fields
        @fields = {}
        config.fields.each do |config|
          @fields[config.name] = Field.new(config, params)
        end
      end

      def fields
        @fields.values
      end

      def field_by_name(name)
        @fields[name]
      end

      def config
        self.class.config
      end
    end
  end
end

