require_relative 'quote'
require 'test/unit'
 
class TestQuote < Test::Unit::TestCase
  def setup
    @cost_params = CostParams.new(0.1, 0.75, 0.5, 0.01)
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

  def test_machine_cost_line_segment
    e = Edge.create([[0, 1], [2, 0]])
    assert_equal((Math.sqrt(5) / 0.5) * 0.01, e.time_cost(@cost_params))
  end

  def test_machine_cost_arc
    speed = 0.5 * Math.exp(-2)
    full_circle = 2 * Math::PI * 0.5

    edge0 = Edge.create([[0, -1], [-0.5, -0.5]], [0, -0.5], 1)
    length = full_circle * (3.0/4.0)
    assert_equal((length / speed) * 0.01, edge0.time_cost(@cost_params))

    edge1 = Edge.create([[0, -1], [-0.5, -0.5]], [0, -0.5], 0)
    length = full_circle * (1.0/4.0)
    assert_equal((length / speed) * 0.01, edge1.time_cost(@cost_params))
  end
end
