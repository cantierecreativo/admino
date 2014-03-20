require 'active_model/naming'
require 'active_model/translation'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

require 'admino/query/dsl'

module Admino
  module Query
    class Base
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      extend Dsl

      attr_reader :params
      attr_reader :filter_groups
      attr_reader :search_fields
      attr_reader :sorting

      def self.i18n_scope
        :query
      end

      def initialize(params = nil, config = nil)
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
        @config = config

        init_filter_groups
        init_search_fields
        init_sorting
      end

      def scope(starting_scope = nil)
        starting_scope ||= if config.starting_scope_callable
                             config.starting_scope_callable.call(self)
                           else
                             raise ArgumentError, 'no starting scope provided'
                           end

        scope_builder = starting_scope

        scope_augmenters = search_fields + filter_groups
        scope_augmenters << sorting if sorting

        scope_augmenters.each do |search_field|
          scope_builder = search_field.augment_scope(scope_builder)
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

      def filter_groups
        @filter_groups.values
      end

      def filter_group_by_name(name)
        @filter_groups[name]
      end

      def search_fields
        @search_fields.values
      end

      def search_field_by_name(name)
        @search_fields[name]
      end

      private

      def init_filter_groups
        @filter_groups = {}
        i18n_key = self.class.model_name.i18n_key
        config.filter_groups.each do |config|
          @filter_groups[config.name] = FilterGroup.new(config, params, i18n_key)
        end
      end

      def init_search_fields
        @search_fields = {}
        config.search_fields.each do |config|
          @search_fields[config.name] = SearchField.new(config, params)
        end
      end

      def init_sorting
        if config.sorting
          @sorting = Sorting.new(config.sorting, params)
        end
      end
    end
  end
end

