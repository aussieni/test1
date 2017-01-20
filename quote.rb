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
  def initialize(vertices, center = nil, clockwise_from_index = nil)
    @vertices = vertices
    @center = center
    @clockwise_from_index = clockwise_from_index
  end

  def is_arc
    !!center
  end

  attr_reader :vertices, :center, :clockwise_from_index

  def time_cost(cost_params)
    length = Math.sqrt((vertices[1][0] - vertices[0][0]) ** 2 +
                       (vertices[1][1] - vertices[0][1]) ** 2)
    (length / cost_params.max_speed) * cost_params.time_cost
  end
end

class CostParams
  # Units: in, dollar/in^2, in/s, dollar/s.
  def initialize(padding, material_cost, max_speed, time_cost)
    @padding = padding
    @material_cost = material_cost
    @max_speed = max_speed
    @time_cost = time_cost
  end

  attr_reader :padding, :material_cost, :max_speed, :time_cost
end
