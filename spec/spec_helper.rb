require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter 'spec'
end

require 'admino'
require 'pry'
require 'rspec-html-matchers'

I18n.enforce_available_locales = true
I18n.available_locales = [:en]
I18n.locale = :en

class ScopeMock
  attr_reader :chain, :name

  def initialize(name = nil, chain = [])
    @name = name
    @chain = chain
  end

  def method_missing(method_name, *args, &block)
    ::ScopeMock.new(name, chain + [method_name, args])
  end
end

class TestQuery < Admino::Query::Base
  search_field :foo
  search_field :starting_from, coerce: :to_date

  filter_by :bar, [:one, :two]

  sorting :by_title, :by_date,
          default_scope: :by_title,
          default_direction: :desc

  starting_scope { 'start' }
  ending_scope { 'end' }
end

class Post < Struct.new(:key, :dom_id)
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def title
    "Post #{key}"
  end

  def author_name
    "steffoz"
  end

  def to_param
    key
  end

  def to_key
    [key]
  end

  def dom_id
    "post_#{key}"
  end
end

require 'action_view'

class RailsViewContext < ActionView::Base
  include ActionView::Helpers::TagHelper
end

RSpec.configure do |c|
  c.before(:each) do
    I18n.backend = I18n::Backend::Simple.new
  end
end

