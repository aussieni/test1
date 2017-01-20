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
  end
end
