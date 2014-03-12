require 'coveralls'
Coveralls.wear!

require 'admino'
require 'pry'

class ScopeMock < BasicObject
  attr_reader :chain

  def initialize
    @chain = []
  end

  def method_missing(method_name, *args, &block)
    self.chain << [method_name, args]
    self
  end
end

