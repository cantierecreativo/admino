require 'active_support/concern'
require 'active_model/naming'
require 'active_model/translation'
require 'active_model/conversion'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

require 'admino/query/dsl'
require 'admino/query/builder'

module Admino
  module Query
    class Base
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      include ActiveModel::Conversion
      extend Dsl

      attr_reader :params
      attr_reader :context
      attr_reader :filter_groups
      attr_reader :search_fields
      attr_reader :sorting

      def self.i18n_scope
        :query
      end

      def initialize(params = nil, context = {}, config = nil)
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
        @config = config
        @context = context

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

        scope = augment_scope(Builder.new(self, starting_scope)).scope

        if config.ending_scope_callable
          scope.instance_exec(self, &config.ending_scope_callable)
        else
          scope
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

      def augment_scope(query_builder)
        scope_augmenters.each do |augmenter|
          query_builder = augmenter.augment_scope(query_builder)
        end

        query_builder
      end

      def scope_augmenters
        scope_augmenters = search_fields + filter_groups
        scope_augmenters << sorting if sorting
        scope_augmenters
      end

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
          i18n_key = self.class.model_name.i18n_key
          @sorting = Sorting.new(config.sorting, params, i18n_key)
        end
      end
    end
  end
end
