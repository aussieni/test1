require 'rubygems'
require 'json'

class Quote
  def initialize(jsonString)
    data = JSON.parse(jsonString)
    @edges = []
  end

  attr_reader :edges
end
