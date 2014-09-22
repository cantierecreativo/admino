require 'active_support/core_ext/hash'
require 'admino/table/presenter'
require 'admino/query/base_presenter'

module Admino
  module ActionViewExtension
    module Internals
      def self.present_query(query, context, options, key = :presenter)
        presenter_klass = options.fetch(key, Admino::Query::BasePresenter)
        presenter_klass.new(query, context)
      end
    end

    def table_for(collection, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter, :class, :query, :html)
      presenter_klass = options.fetch(:presenter, Admino::Table::Presenter)
      query = if options[:query]
                Internals.present_query(options[:query], self, options, :query_presenter)
              else
                nil
              end
      presenter = presenter_klass.new(collection, options[:class], query, self)
      html_options = options.fetch(:html, {})
      presenter.to_html(html_options, &block)
    end

    def filters_for(query, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter)
      Internals.present_query(query, self, options).filter_groups.each(&block)
    end

    def sortings_for(query, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter)
      Internals.present_query(query, self, options).sorting.scopes.each(&block)
    end

    def search_form_for(query, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter)
      Internals.present_query(query, self, options).form(&block)
    end

    def simple_search_form_for(query, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter)
      Internals.present_query(query, self, options).simple_form(&block)
    end
  end
end

