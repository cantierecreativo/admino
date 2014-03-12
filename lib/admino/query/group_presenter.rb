require 'showcase'

module Admino
  module Query
    class GroupPresenter < Showcase::Presenter
      def scope_link(scope, options = {})
        options = Showcase::Helpers::HtmlOptions.new(options)

        active_class = options.fetch(:active_class, 'is-active')

        if is_scope_active?(scope)
          options.add_class!(active_class)
        end

        h.link_to scope_name(scope), scope_url(scope), options.to_h
      end

      def scope_url(scope)
        params = h.request.query_parameters.dup

        if scope
          params.merge!(param_name => scope)
        else
          params.delete(param_name)
        end

        h.request.path + "?" + params.to_query
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
          default: config.name.to_s.titleize
        )
      end
    end
  end
end

