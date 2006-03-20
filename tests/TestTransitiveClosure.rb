require 'test/unit'
require 'rgl/transitiv_closure'

include RGL

class TestTransitiveClosure < Test::Unit::TestCase

  def setup
    @dg = DirectedAdjacencyGraph.new(Array)
	edges = [[1,2],[2,3],[2,4],[4,5],[1,6],[6,4]]
    edges.each do |(src,target)| 
      @dg.add_edge(src, target)
    end
  end

  def test_transitive_closure
	assert_equal("(1-2)(1-3)(1-4)(1-6)(2-3)(2-4)(2-5)(4-5)(6-4)(6-5)",
				 @dg.transitive_closure.to_s)
  end

  def test_transitive_closure_undirected
	assert_raises(NotDirectedError) {AdjacencyGraph.new.transitive_closure}
  end
end

