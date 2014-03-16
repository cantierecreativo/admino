require 'admino/table/row'
require 'showcase/helpers/html_options'

module Admino
  module Table
    class ResourceRow < Row
      attr_reader :resource

      def initialize(resource, view_context)
        @resource = resource
        @columns = ""
        @actions = []

        super(view_context)
      end

      def column(*args, &block)
        params = parse_column_args(args)

        attribute_name = params[:attribute_name]
        label = params[:label]
        options = params[:html_options]

        if block_given?
          content = h.capture(resource, &block)
        elsif attribute_name.present?
          content = resource.send(attribute_name)
        else
          raise ArgumentError, 'attribute name or block required'
        end

        default_options = column_html_options(attribute_name)
        html_options = Showcase::Helpers::HtmlOptions.new(default_options)
        html_options.merge_attrs!(options)

        @columns << h.content_tag(:td, content, html_options.to_h)
      end

      def actions(*actions, &block)
        if block_given?
          h.capture(&block)
        else
          actions.each do |action|
            action(action)
          end
        end
      end

      def action(*args, &block)
        params = parse_action_args(args)

        action_name = params[:action_name]
        label = params[:label]
        url = params[:url]
        options = params[:html_options]

        if block_given?
          @actions << h.capture(resource, &block)
          return
        end

        if url.nil?
          if action_name.nil?
            raise ArgumentError, 'no URL provided, action name required'
          end

          action_url_method = "#{action_name}_action_url"

          if !respond_to?(action_url_method, true)
            raise ArgumentError,
                  "no URL provided, ##{action_url_method} method required"
          end

          url = send(action_url_method)
        end

        base_options = if action_name
                         action_html_options(action_name)
                       end

        html_options = Showcase::Helpers::HtmlOptions.new(base_options)

        action_html_options_method = "#{action_name}_action_html_options"

        if respond_to?(action_html_options_method, true)
          action_html_options = send(action_html_options_method)
          html_options.merge_attrs!(action_html_options)
        end

        html_options.merge_attrs!(options)

        if label.nil? && action_name
          label = I18n.t(
            :"#{resource.class.model_name.i18n_key}.#{action_name}",
            scope: 'table.actions',
            default: [
              :"#{action_name}",
              action_name.to_s.titleize
            ]
          )
        end

        @actions << h.link_to(label, url, html_options.to_h)
      end

      def to_html
        buffer = @columns

        if @actions.any?
          html_options = column_html_options(:actions)
          buffer << h.content_tag(:td, html_options) do
            @actions.join(" ").html_safe
          end
        end

        buffer.html_safe
      end

      private

      def action_html_options(action_name)
        if action_name
          { role: action_name.to_s.gsub(/_/, '-') }
        end
      end

      def column_html_options(attribute_name)
        if attribute_name
          { role: attribute_name.to_s.gsub(/_/, '-') }
        end
      end
    end
  end
end

