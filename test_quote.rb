require_relative 'quote'
require 'test/unit'
 
class TestQuote < Test::Unit::TestCase
  def setup
    @cost_params = CostParams.new(0.1, 0.3, 0.5, 0.01)
  end
  
  def test_parse
    json = IO.read('CutCircularArc.json')
    quote = Quote.new(json)
    edges = quote.edges
    
    assert_equal(4, edges.length)

    edge0 = edges[0]
    assert_equal([[0.0, 0.0], [2.0, 0.0]], edge0.vertices)
    assert_equal(false, edge0.is_arc)

    edge1 = edges[1]
    assert_equal([[2.0, 0.0], [2.0, 1.0]], edge1.vertices)
    assert_equal(true, edge1.is_arc)
    assert_equal([2.0, 0.5], edge1.center)
    assert_equal(0, edge1.clockwise_from_index)
  end

  def test_time_cost_line_segment
    e = Edge.create([[0, 1], [2, 0]])
    assert_close (Math.sqrt(5) / 0.5) * 0.01, e.time_cost(@cost_params)
  end

  def test_time_cost_arc
    speed = 0.5 * Math.exp(-2)
    full_circle = 2 * Math::PI * 0.5

    edge0 = Edge.create([[0, -1], [-0.5, -0.5]], [0, -0.5], 1)
    length = full_circle * (3.0/4.0)
    assert_close (length / speed) * 0.01, edge0.time_cost(@cost_params)

    edge1 = Edge.create([[0, -1], [-0.5, -0.5]], [0, -0.5], 0)
    length = full_circle * (1.0/4.0)
    assert_close (length / speed) * 0.01, edge1.time_cost(@cost_params)
  end

  def test_material_cost_line_segment
    e = Edge.create([[0, 1], [2, 0]])
    assert_close 1.2 * 2.2 * 0.3, e.material_cost(@cost_params)
  end

  def test_material_cost_arc
    # Side length of isosceles right triangle with hypotenuse 1.
    a = Math.sqrt(1.0 / 2.0)
    
    e0 = Edge.create([[0, 1], [1 + a, 1 - a]], [1, 1], 0)
    assert_close 2.2 * (1 + a + 0.2) * 0.3, e0.material_cost(@cost_params)

    e1 = Edge.create([[0, 1], [1 + a, 1 - a]], [1, 1], 1) 
    assert_close (1 + a + 0.2) * 1.2 * 0.3, e1.material_cost(@cost_params)
  end

  def assert_close(expected, actual)
    assert_in_delta expected, actual
  end
end
