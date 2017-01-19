require_relative 'quote'
require 'test/unit'
 
class TestQuote < Test::Unit::TestCase
  def test_parse
    json = IO.read('CutCircularArc.json')
    quote = Quote.new(json)
    assert_equal(4, quote.edges.length)
  end
end
