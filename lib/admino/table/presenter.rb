require 'showcase'
require 'admino/table/head_row'
require 'admino/table/resource_row'

module Admino
  module Table
    class Presenter < Showcase::Presenter
      attr_reader :collection_klass

      def self.tag_helper(name, tag, options = {})
        default_options_method = :"#{name}_html_options"

        define_method :"#{name}_tag" do |*args, &block|
          options = args.extract_options!
          if respond_to?(default_options_method, true)
            default_options = send(default_options_method, *args)
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

      def initialize(collection, klass, context)
        @collection_klass = klass
        super(collection, context)
      end

      def to_html(options = {}, &block)
        table_tag(options) do
          thead_tag do
            thead_tr_tag do
              row = head_row(collection_klass, view_context)
              h.capture(row, nil, &block) if block_given?
              row.to_html
            end
          end <<
          tbody_tag do
            collection.each_with_index.map do |resource, index|
              tr_html_options = {
                class: zebra_css_classes[index % zebra_css_classes.size],
                id: resource.dom_id
              }
              tbody_tr_tag(resource, index, tr_html_options) do
                row = resource_row(resource, view_context)
                h.capture(row, resource, &block) if block_given?
                row.to_html
              end
            end.join.html_safe
          end
        end
      end

      private

      def collection
        @collection ||= present_collection(object)
      end

      def head_row(collection_klass, view_context)
        HeadRow.new(collection_klass, view_context)
      end

      def resource_row(resource, view_context)
        ResourceRow.new(resource, view_context)
      end

      def zebra_css_classes
        %w(is-even is-odd)
      end
    end
  end
end

