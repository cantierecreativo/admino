require 'active_support/core_ext/hash'
require 'admino/table/presenter'
require 'admino/query/base_presenter'

module Admino
  module ActionViewExtension
    module Internals
      def self.present_query(query, context, options)
        presenter_klass = options.fetch(:presenter, Admino::Query::BasePresenter)
        presenter_klass.new(query, context)
      end
    end

    def table_for(collection, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter, :class, :html)
      presenter_klass = options.fetch(:presenter, Admino::Table::Presenter)
      presenter = presenter_klass.new(collection, options[:class], self)
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

