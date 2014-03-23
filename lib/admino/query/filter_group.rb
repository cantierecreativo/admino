require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Admino
  module Query
    class FilterGroup
      attr_reader :params
      attr_reader :config
      attr_reader :query_i18n_key

      def initialize(config, params, query_i18n_key = nil)
        @config = config
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
        @query_i18n_key = query_i18n_key
      end

      def augment_scope(scope)
        if active_scope
          scope.send(active_scope)
        else
          scope
        end
      end

      def active_scope
        if value && scopes.include?(value.to_sym)
          value.to_sym
        else
          nil
        end
      end

      def is_scope_active?(scope)
        active_scope == scope.to_sym
      end

      def value
        params.fetch(:query, {}).fetch(param_name, nil)
      end

      def param_name
        config.name
      end

      def scopes
        config.scopes
      end

      def i18n_key
        config.name
      end
    end
  end
end

