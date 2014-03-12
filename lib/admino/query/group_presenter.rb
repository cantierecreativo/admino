require 'i18n'
require 'showcase'
require 'showcase/helpers/html_options'
require 'active_support/core_ext/array/extract_options'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Admino
  module Query
    class GroupPresenter < Showcase::Presenter
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
        params = ActiveSupport::HashWithIndifferentAccess.new(h.request.query_parameters)

        if scope
          params.merge!(param_name => scope.to_s)
        else
          params.delete(param_name)
        end

        params
      end

      def scope_name(scope)
        I18n.t(
          scope || :none,
          scope: [:query, :groups, query_i18n_key, i18n_key, :scopes],
          default: scope.to_s.titleize
        )
      end

      def name
        I18n.t(
          :name,
          scope: [:query, :groups, query_i18n_key, i18n_key],
          default: i18n_key.to_s.titleize
        )
      end
    end
  end
end

