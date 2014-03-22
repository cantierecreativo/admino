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
        attribute_name, label, html_options = parse_column_args(args)

        html_options = complete_column_html_options(
          attribute_name,
          html_options
        )

        if block_given?
          content = h.capture(resource, &block)
        elsif attribute_name.present?
          content = resource.send(attribute_name)
        else
          raise ArgumentError, 'attribute name or block required'
        end

        @columns << h.content_tag(:td, content, html_options)
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
        if block_given?
          @actions << h.capture(resource, &block)
        else
          action_name, url, label, html_options = parse_action_args(args)

          label ||= action_label(action_name)
          url ||= action_url(action_name)
          html_options = complete_action_html_options(
            action_name,
            html_options
          )

          @actions << h.link_to(label, url, html_options)
        end
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

      def action_url(action_name)
        if action_name.nil?
          raise ArgumentError,
                'no URL provided, action name required'
        end

        action_url_method = "#{action_name}_action_url"

        if !respond_to?(action_url_method, true)
          raise ArgumentError,
                "no URL provided, ##{action_url_method} method required"
        end

        url = send(action_url_method)
      end

      def complete_action_html_options(action_name, final_html_options)
        if action_name
          default_options = column_html_options(action_name)
          html_options = Showcase::Helpers::HtmlOptions.new(default_options)

          action_html_options_method = "#{action_name}_action_html_options"
          if respond_to?(action_html_options_method, true)
            html_options.merge_attrs!(send(action_html_options_method))
          end

          html_options.merge_attrs!(final_html_options)
          html_options.to_h
        else
          final_html_options
        end
      end

      def complete_column_html_options(attribute_name, final_html_options)
        if attribute_name
          default_options = column_html_options(attribute_name)
          html_options = Showcase::Helpers::HtmlOptions.new(default_options)
          html_options.merge_attrs!(final_html_options)
          html_options.to_h
        else
          final_html_options
        end
      end

      def action_label(action_name)
        return nil unless action_name

        I18n.t(
          :"#{resource.class.model_name.i18n_key}.#{action_name}",
          scope: 'table.actions',
          default: [
            :"#{action_name}",
            action_name.to_s.titleize
          ]
        )
      end

      def action_html_options(action_name)
        { role: action_name.to_s.gsub(/_/, '-') }
      end

      def column_html_options(attribute_name)
        { role: attribute_name.to_s.gsub(/_/, '-') }
      end
    end
  end
end

