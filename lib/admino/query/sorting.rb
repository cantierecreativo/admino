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
          scope.send(active_scope, ascendent? ? :asc : :desc)
        else
          scope
        end
      end

      def ascendent?
        if params[:sort_order] == 'desc'
          false
        elsif params[:sort_order].blank? && active_scope == default_scope
          default_direction_is_ascendent?
        else
          true
        end
      end

      def active_scope
        if param_value && available_scopes.include?(param_value.to_sym)
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

      def default_direction_is_ascendent?
        config.default_direction != :desc
      end

      def param_value
        params.fetch(param_name, nil)
      end

      def param_name
        :sorting
      end

      def available_scopes
        config.scopes
      end

      def scope_name
        config.name
      end
    end
  end
end

