require 'active_support/hash_with_indifferent_access'

module Admino
  module Query
    class Group
      attr_reader :params
      attr_reader :config
      attr_reader :query_i18n_key

      def initialize(config, params, query_i18n_key = nil)
        @config = config
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
        @query_i18n_key = query_i18n_key
      end

      def augment_scope(scope)
        if current_scope
          scope.send(current_scope)
        else
          scope
        end
      end

      def current_scope
        if param_value && available_scopes.include?(param_value.to_sym)
          param_value.to_sym
        else
          nil
        end
      end

      def is_scope_active?(scope)
        current_scope == scope
      end

      def param_value
        params.fetch(param_name, nil)
      end

      def param_name
        config.name
      end

      def available_scopes
        [nil] + config.scopes
      end

      def i18n_key
        config.name
      end
    end
  end
end

