require 'test/unit'
require 'rgl/adjacency'

include RGL

class TestGraph < Test::Unit::TestCase

  def setup
    @dg = DirectedAdjacencyGraph.new(Array)
    edges = [[1,2],[2,3],[2,4],[4,5],[1,6],[6,4]]
    edges.each do |(src,target)| 
      @dg.add_edge(src, target)
    end

    @ug = AdjacencyGraph.new(Array)
    @ug.add_edges(*edges)
  end

  def test_equality
    assert @dg == DirectedAdjacencyGraph.new(@dg)
    assert @ug == AdjacencyGraph.new(@ug)
    assert @ug != DirectedAdjacencyGraph.new(@dg)
    assert @dg != AdjacencyGraph.new(@ug)
    assert @dg == DirectedAdjacencyGraph[6,4,1,2,2,3,2,4,4,5,1,6]
  end

  def test_merge
    merge = DirectedAdjacencyGraph.new(Array, @dg, @ug)
    assert merge.edges.size == 12
    merge = DirectedAdjacencyGraph.new(Set, @dg, @dg)
    assert merge.edges.size == 6
    assert_raise(ArgumentError) {DirectedAdjacencyGraph.new([])}
  end

end
