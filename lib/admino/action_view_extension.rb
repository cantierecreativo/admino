require 'active_support/core_ext/hash'
require 'admino/table/presenter'
require 'admino/query/base_presenter'

module Admino
  module ActionViewExtension
    def simple_table_for(collection, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter, :class)
      presenter_klass = options.fetch(:presenter, Admino::Table::Presenter)
      presenter_klass.new(collection, options[:class], self).to_html(&block)
    end

    def simple_filters_for(query, options = {}, &block)
      options.symbolize_keys!
      options.assert_valid_keys(:presenter)
      presenter_klass = options.fetch(:presenter, Admino::Query::BasePresenter)
      presenter = presenter_klass.new(query, self)
      presenter.filter_groups.each(&block)
    end
  end
end

