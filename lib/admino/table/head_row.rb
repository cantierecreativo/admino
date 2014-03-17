require 'admino/table/row'
require 'showcase/helpers/html_options'

module Admino
  module Table
    class HeadRow < Row
      attr_reader :resource_klass
      attr_reader :query

      def initialize(resource_klass, query, view_context)
        @resource_klass = resource_klass
        @query = query
        @columns = ""

        super(view_context)
      end

      def actions(*args, &block)
        default_options = column_html_options(:actions)
        label = I18n.t(
          :"#{resource_klass.model_name.i18n_key}.title",
          scope: 'table.actions',
          default: [ :title, 'Actions' ]
        )

        @columns << h.content_tag(:th, label.to_s, default_options)
      end

      def column(*args, &block)
        params = parse_column_args(args)

        attribute_name = params[:attribute_name]
        label = params[:label]
        options = params[:html_options]

        if label.nil? && attribute_name
          label = resource_klass.human_attribute_name(attribute_name.to_s)
        end

        default_options = column_html_options(attribute_name)
        html_options = Showcase::Helpers::HtmlOptions.new(default_options)
        html_options.merge_attrs!(options)
        html_options = html_options.to_h

        sorting_scope = html_options.delete(:sorting)
        sorting_html_options = html_options.delete(:sorting_html_options) { {} }
        if sorting_scope
          raise ArgumentError, 'query object is required' unless query
          label = query.sorting.scope_link(sorting_scope, label, sorting_html_options)
        end

        @columns << h.content_tag(:th, label.to_s, html_options)
      end

      def to_html
        @columns.html_safe
      end

      private

      def column_html_options(attribute_name)
        if attribute_name
          { role: attribute_name.to_s.gsub(/_/, '-') }
        end
      end
    end
  end
end

