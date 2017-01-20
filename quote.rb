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
      Edge.create(vertices, center, clockwise_from_index)
    end
  end

  attr_reader :edges

  private

  def time_cost(cost_params)
    edges.map { |e| e.time_cost(cost_params) }.reduce(0, :+)
  end
end

class Edge
  def self.create(vertices, center = nil, clockwise_from_index = nil)
    center ?
      Arc.new(vertices, center, clockwise_from_index) :
      LineSegment.new(vertices)
  end

  attr_reader :vertices

  def material_cost(cost_params)
    rect = BoundingRectangle.new(extreme_points)
    padding = cost_params.padding
    padded_area = (rect.x1 + padding - (rect.x0 - padding)) *
                  (rect.y1 + padding - (rect.y0 - padding))
    padded_area * cost_params.material_cost
  end

  def time_cost(cost_params)
    (length / speed(cost_params.max_speed)) * cost_params.time_cost
  end

  protected

  def distance(p0, p1)
    Math.sqrt((p1[0] - p0[0]) ** 2 + (p1[1] - p0[1]) ** 2)
  end

  private
  
  def initialize(vertices)
    @vertices = vertices
  end
end

class LineSegment < Edge
  def is_arc
    false
  end

  private

  def extreme_points
    vertices
  end

  def length
    distance(vertices[0], vertices[1])
  end

  def speed(max_speed)
    max_speed
  end
end

class Arc < Edge
  def initialize(vertices, center, clockwise_from_index)
    super(vertices)
    @center = center
    @clockwise_from_index = clockwise_from_index
  end

  attr_reader :center, :clockwise_from_index

  def is_arc
    true
  end

  private

  def length
    shifted_vertices = vertices.map { |v| [v[0] - center[0], v[1] - center[1]] }
    angles = shifted_vertices.map { |v| Math::atan2(v[1], v[0]) }
    cc_angle_diff = angles[1] - angles[0]
    angle_diff = clockwise_from_index == 0 ? -cc_angle_diff : cc_angle_diff
    angle_distance = angle_diff.modulo(2 * Math::PI)
    angle_distance * radius
  end

  def speed(max_speed)
    max_speed * Math.exp(-1 / radius)
  end

  def radius
    distance(vertices[0], center)
  end
end

class BoundingRectangle
  def initialize(points)
    x_values = points.map { |p| p[0] }
    y_values = points.map { |p| p[1] }
    @x0 = x_values.min
    @x1 = x_values.max
    @y0 = y_values.min
    @y1 = y_values.max
  end

  attr_reader :x0, :x1, :y0, :y1
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
