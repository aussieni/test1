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

  def cost(cost_params)
    cost = material_cost(cost_params) + time_cost(cost_params)
    sprintf('%.2f', cost)
  end

  # We divide the circle into this many parts to find the best rotation.
  ANGLE_RESOLUTION = 8

  private

  def material_cost(cost_params)
    padded_areas = (0...ANGLE_RESOLUTION).to_a.map do |i|
      angle = (i.to_f / ANGLE_RESOLUTION) * 2 * Math::PI
      rect = bound_rect(angle)
      (rect.x1 - rect.x0 + cost_params.padding) *
        (rect.y1 - rect.y0 + cost_params.padding)
    end
    padded_areas.min * cost_params.material_cost
  end

  def bound_rect(angle)
    edges.map { |e| e.rotated(angle) }
       .map { |e| e.bound_rect }
      .reduce { |acc, new_value| acc.union(new_value) }
  end

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

  def bound_rect
    rect = BoundRect.new(extreme_points)
  end

  def time_cost(cost_params)
    (length / speed(cost_params.max_speed)) * cost_params.time_cost
  end

  protected

  def distance(p0, p1)
    Math.sqrt((p1[0] - p0[0]) ** 2 + (p1[1] - p0[1]) ** 2)
  end

  def rotated_point(p, angle)
    [
      Math.cos(angle) * p[0] - Math.sin(angle) * p[1],
      Math.sin(angle) * p[0] + Math.cos(angle) * p[1]
    ]
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

  def rotated(angle)
    LineSegment.new(vertices.map { |v| rotated_point(v, angle) })
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

  def rotated(angle)
    Arc.new(vertices.map { |v| rotated_point(v, angle) }, 
            rotated_point(center, angle), clockwise_from_index)
  end

  private

  def extreme_points
    unit_circle_extremes = [[1, 0], [0, 1], [-1, 0], [0, -1]]
    circle_extremes = unit_circle_extremes.map do |p|
      [p[0] * radius + center[0], p[1] * radius + center[1]]
    end
    included_circle_extremes = circle_extremes.find_all do |p|
      in_cc_order(cc_vertices[0], p, cc_vertices[1])
    end
    vertices + included_circle_extremes
  end

  def length
    cc_angle_distance(cc_vertices) * radius
  end

  # Counter-clockwise, following the math standard.
  def cc_vertices
    clockwise_from_index == 0 ? vertices.reverse : vertices
  end
  
  def cc_angle_distance(points)
    shifted_points = points.map { |p| [p[0] - center[0], p[1] - center[1]] }
    angles = shifted_points.map { |p| Math::atan2(p[1], p[0]) }
    (angles[1] - angles[0]).modulo(2 * Math::PI)
  end

  def in_cc_order(p0, p1, p2)
    cc_angle_distance([p0, p1]) <= cc_angle_distance([p0, p2])
  end

  def speed(max_speed)
    max_speed * Math.exp(-1 / radius)
  end

  def radius
    distance(vertices[0], center)
  end
end

class BoundRect
  def initialize(points)
    x_values = points.map { |p| p[0] }
    y_values = points.map { |p| p[1] }
    @x0 = x_values.min
    @x1 = x_values.max
    @y0 = y_values.min
    @y1 = y_values.max
  end

  def union(boundRect)
    BoundRect.new([[x0, y0], [x1, y1],
                   [boundRect.x0, boundRect.y0], [boundRect.x1, boundRect.y1]])
  end

  attr_reader :x0, :x1, :y0, :y1

  def ==(other)
    x0 == other.x0 && x1 == other.x1 && y0 == other.y0 && y1 == other.y1
  end

  def to_s
    "[#{x0}, #{x1}]x[#{y0}, #{y1}]"
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
