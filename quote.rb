require 'rubygems'
require 'json'

class Quote
  def initialize(jsonString)
    data = JSON.parse(jsonString)
    @edges = data['Edges'].values.map do |e|
      vertices = e['Vertices'].map do |v_id|
        position = data['Vertices'][v_id.to_s]['Position']
        ([position['X'], position['Y']])
      end
      Edge.new(vertices)
    end
  end

  attr_reader :edges
end

class Edge
  def initialize(vertices)
    @vertices = vertices
  end

  def is_arc
    !!center
  end

  def center
    nil
  end

  attr_reader :vertices
end
