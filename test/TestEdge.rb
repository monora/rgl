require 'test/unit'
require 'rgl/base'

include RGL::Edge

class TestEdge < Test::Unit::TestCase
  
  def test_directed_edge
    assert_raises(ArgumentError) {DirectedEdge.new}
    e = DirectedEdge.new 1,2
    assert_equal(1,e.source)
    assert_equal(2,e.target)
    assert_equal([1,2],e.to_a)
    assert_equal("(1-2)",e.to_s)
    assert_equal("(2-1)",e.reverse.to_s)
    assert_equal([1,2],[e[0],e[1]])
    assert(DirectedEdge[1,2].eql?(DirectedEdge.new(1,2)))
    assert(!DirectedEdge[1,2].eql?(DirectedEdge.new(1,3)))
    assert(!DirectedEdge[2,1].eql?(DirectedEdge.new(1,2)))
  end
  
  def test_undirected_edge
    assert_raises(ArgumentError) {UnDirectedEdge.new}
    e = UnDirectedEdge.new 1,2
    assert_equal(1,e.source)
    assert_equal(2,e.target)
    assert_equal([1,2],e.to_a)
    assert_equal("(1=2)",e.to_s)
    assert(UnDirectedEdge.new(1,2).eql?(UnDirectedEdge.new(2,1)))
    assert(!UnDirectedEdge.new(1,3).eql?(UnDirectedEdge.new(2,1)))
    assert_equal(UnDirectedEdge.new(1,2).hash,UnDirectedEdge.new(1,2).hash)
  end
  
end
