require 'showcase'

module Admino
  module Query
    class SortingPresenter < Showcase::Presenter
      def scope_link(scope, *args)
        options = args.extract_options!

        label = args.first || scope_name(scope)

        desc_class = options.delete(:desc_class) { 'is-desc' }
        asc_class = options.delete(:asc_class) { 'is-asc' }

        options = Showcase::Helpers::HtmlOptions.new(options)

        if is_scope_active?(scope)
          options.add_class!(ascending? ? asc_class : desc_class)
        end

        h.link_to label, scope_path(scope), options.to_h
      end

      def scope_path(scope)
        h.request.path + "?" + scope_params(scope).to_query
      end

      def scope_params(scope)
        params = ActiveSupport::HashWithIndifferentAccess.new(h.request.query_parameters)

        if is_scope_active?(scope)
          params.merge!(sorting: scope.to_s, sort_order: ascending? ? 'desc' : 'asc')
        elsif default_scope == scope
          params.merge!(sorting: scope.to_s, sort_order: default_direction.to_s)
        else
          params.merge!(sorting: scope.to_s, sort_order: 'asc')
        end

        params
      end

      def scope_name(scope)
        I18n.t(
          :"#{query_i18n_key}.#{scope}",
          scope: 'query.sorting_scopes',
          default: scope.to_s.titleize.capitalize
        )
      end
    end
  end
end

