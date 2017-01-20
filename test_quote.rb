require_relative 'quote'
require 'test/unit'
 
class TestQuote < Test::Unit::TestCase
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
end
