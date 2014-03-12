require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Admino
  module Query
    class Field
      attr_reader :params
      attr_reader :config

      def initialize(config, params)
        @config = config
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
      end

      def augment_scope(scope)
        if present?
          scope.send(scope_name, value)
        else
          scope
        end
      end

      def value
        params.fetch(:query, {}).fetch(param_name, nil)
      end

      def present?
        value.present?
      end

      def param_name
        config.name
      end

      def scope_name
        config.name
      end
    end
  end
end

