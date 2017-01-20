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
      center = e['Center'] && [e['Center']['X'], e['Center']['Y']]
      clockwise_from_index = e['ClockwiseFrom'] && e['Vertices'].index(e['ClockwiseFrom'])
      Edge.new(vertices, center, clockwise_from_index)
    end
  end

  attr_reader :edges
end

class Edge
  def initialize(vertices, center, clockwise_from_index)
    @vertices = vertices
    @center = center
    @clockwise_from_index = clockwise_from_index
  end

  def is_arc
    !!center
  end

  attr_reader :vertices, :center, :clockwise_from_index
end
