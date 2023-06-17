require 'test/unit'

# Do not require rgl/adjacency !
require 'rgl/traversal'
require 'rgl/implicit'

include RGL

# Cyclic graph with _n_ vertices. Need a concrete graph, that is not an AdjacencyGraph
def cycle(n)
  RGL::ImplicitGraph.new { |g|
    g.vertex_iterator { |b| 0.upto(n - 1, &b) }
    g.adjacent_iterator { |x, b| b.call((x + 1) % n) }
    g.directed = true
  }
end

class TestAdjacencyNotRequired < Test::Unit::TestCase

  def setup
    @dg = cycle(4)
  end

  def test_bfs_search_tree
    # bfs_search_tree_from requires rgl/adjacency if not yet loaded.
    assert_equal("(1-2)(2-3)(3-0)", @dg.bfs_search_tree_from(1).edges.sort.join)
  end

end
