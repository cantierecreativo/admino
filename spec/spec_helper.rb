require 'coveralls'
Coveralls.wear!

require 'admino'
require 'pry'

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

