require 'showcase'
require 'admino/table/head_row'
require 'admino/table/resource_row'

module Admino
  module Table
    class Presenter < Showcase::Presenter
      attr_reader :collection_klass
      attr_reader :query

      def self.tag_helper(name, tag, options = {})
        options_method = :"#{name}_html_options"

        define_method :"#{name}_tag" do |*args, &block|
          options = args.extract_options!
          if respond_to?(options_method, true)
            default_options = send(options_method, *args)
            html_options = Showcase::Helpers::HtmlOptions.new(default_options)
            html_options.merge_attrs!(options)
            options = html_options.to_h
          end
          h.content_tag(tag, options, &block)
        end
      end

      tag_helper :table,    :table
      tag_helper :thead,    :thead
      tag_helper :thead_tr, :tr
      tag_helper :tbody,    :tbody
      tag_helper :tbody_tr, :tr, params: %w(resource index)

      def initialize(*args)
        context = args.pop
        collection = args.shift

        @collection_klass = args.shift || collection.first.class
        @query = args.shift

        super(collection, context)
      end

      def to_html(options = {}, &block)
        table_tag(options) do
          thead_tag do
            thead_tr_tag do
              th_tags(&block)
            end
          end <<
          tbody_tag do
            tbody_tr_tags(&block)
          end
        end
      end

      private

      def tbody_tr_tags(&block)
        collection.each_with_index.map do |resource, index|
          html_options = base_tbody_tr_html_options(resource, index)
          tbody_tr_tag(resource, index, html_options) do
            td_tags(resource, &block)
          end
        end.join.html_safe
      end

      def th_tags(&block)
        row = head_row(collection_klass, query, view_context)
        if block_given?
          h.capture(row, nil, &block)
        end
        row.to_html
      end

      def td_tags(resource, &block)
        row = resource_row(resource, view_context)
        if block_given?
          h.capture(row, resource, &block)
        end
        row.to_html
      end

      def collection
        object
      end

      def head_row(collection_klass, query, view_context)
        HeadRow.new(collection_klass, query, view_context)
      end

      def resource_row(resource, view_context)
        ResourceRow.new(resource, view_context)
      end

      def base_tbody_tr_html_options(resource, index)
        options = {
          class: zebra_css_classes[index % zebra_css_classes.size]
        }

        if resource.respond_to?(:dom_id)
          options[:id] = resource.dom_id
        end

        options
      end

      def zebra_css_classes
        %w(is-even is-odd)
      end
    end
  end
end

