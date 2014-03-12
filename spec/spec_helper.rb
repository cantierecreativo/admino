require 'coveralls'
Coveralls.wear!

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
  field :foo
  group :bar, [:one, :two]

  starting_scope { 'start' }
  ending_scope { 'end' }
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

