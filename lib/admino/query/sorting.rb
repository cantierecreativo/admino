require 'coercible'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Admino
  module Query
    class Sorting
      attr_reader :params
      attr_reader :config

      def initialize(config, params)
        @config = config
        @params = ActiveSupport::HashWithIndifferentAccess.new(params)
      end

      def augment_scope(scope)
        if active_scope
          scope.send(active_scope, ascending? ? :asc : :desc)
        else
          scope
        end
      end

      def is_scope_active?(scope)
        active_scope == scope
      end

      def ascending?
        if params[:sort_order] == 'desc'
          false
        elsif params[:sort_order].blank? && active_scope == default_scope
          default_direction_is_ascending?
        else
          true
        end
      end

      def active_scope
        if param_value && scopes.include?(param_value.to_sym)
          param_value.to_sym
        elsif default_scope
          default_scope
        else
          nil
        end
      end

      def default_scope
        config.default_scope
      end

      def default_direction
        config.default_direction
      end

      def default_direction_is_ascending?
        default_direction != :desc
      end

      def param_value
        params.fetch(param_name, nil)
      end

      def param_name
        :sorting
      end

      def scopes
        config.scopes
      end
    end
  end
end

