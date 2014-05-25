require 'i18n'
require 'showcase'
require 'showcase/helpers/html_options'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/array/extract_options'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Admino
  module Query
    class FilterGroupPresenter < Showcase::Presenter
      def scope_link(scope, *args)
        options = args.extract_options!

        label = args.first || scope_name(scope)

        active_class = options.delete(:active_class) { 'is-active' }
        options = Showcase::Helpers::HtmlOptions.new(options)

        if is_scope_active?(scope)
          options.add_class!(active_class)
        end

        h.link_to label, scope_path(scope), options.to_h
      end

      def scope_path(scope)
        h.request.path + "?" + scope_params(scope).to_query
      end

      def scope_params(scope)
        params = ActiveSupport::HashWithIndifferentAccess.new(
          h.request.query_parameters.deep_dup
        )

        params[:query] ||= {}

        if is_scope_active?(scope)
          params[:query].delete(param_name)
        else
          params[:query].merge!(param_name => scope.to_s)
        end

        if params[:query].empty?
          params.delete(:query)
        end

        params
      end

      def scope_name(scope)
        I18n.t(
          :"#{query_i18n_key}.#{i18n_key}.scopes.#{scope}",
          scope: 'query.filter_groups',
          default: [
            :"#{i18n_key}.scopes.#{scope}",
            scope.to_s.titleize
          ]
        )
      end

      def name
        I18n.t(
          :"#{query_i18n_key}.#{i18n_key}.name",
          scope: 'query.filter_groups',
          default: [
            :"#{i18n_key}.name",
            i18n_key.to_s.titleize.capitalize
          ]
        )
      end
    end
  end
end

