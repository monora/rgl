require 'test/unit'
require 'rgl/transitivity'
require 'test_helper'

include RGL

class TestTransitiveClosure < Test::Unit::TestCase

  def setup
    @dg = DirectedAdjacencyGraph.new
    @dg.add_edges([1,2],[2,3],[2,4],[4,5],[1,6],[6,4])
    @dg_tc = DirectedAdjacencyGraph.new
    @dg_tc.add_edges(
      [1,2],[1,3],[1,4],[1,5],[1,6],
      [2,3],[2,4],[2,5],
      [4,5],
      [6,4],[6,5]
    )
    @dg_tr = DirectedAdjacencyGraph.new
    @dg_tr.add_edges(
      [1,2],[1,6],
      [2,3],[2,4],
      [4,5],
      [6,4]
    )

    @dg_loner = @dg.dup
    @dg_loner.add_vertices(7, 8, 9)
    @dg_loner_tc = @dg_tc.dup
    @dg_loner_tc.add_vertices(7, 8, 9)
    @dg_loner_tr = @dg_tr.dup
    @dg_loner_tr.add_vertices(7, 8, 9)

    @dg_cyclic = DirectedAdjacencyGraph.new
    @dg_cyclic.add_edges(
      [1,1],[1,2],
      [2,3],
      [3,4],
      [4,5],
      [5,6],
      [6,3]
    )
    @dg_cyclic_tc = DirectedAdjacencyGraph.new
    @dg_cyclic_tc.add_edges(
      [1,1],[1,2],[1,3],[1,4],[1,5],[1,6],
      [2,3],[2,4],[2,5],[2,6],
      [3,3],[3,4],[3,5],[3,6],
      [4,3],[4,4],[4,5],[4,6],
      [5,3],[5,4],[5,5],[5,6],
      [6,3],[6,4],[6,5],[6,6]
    )
    @dg_cyclic_tr = DirectedAdjacencyGraph.new
    @dg_cyclic_tr.add_edges(
      [1,1],[1,2],
      [2,3],
      [3,4],
      [4,5],
      [5,6],
      [6,3]
    )
  end

  def test_transitive_closure
    # A simple graph without cycles.
    assert_equal(@dg_tc, @dg.transitive_closure)

    # Iterative applications of transitive closure should return the same result
    # as a single application.
    assert_equal(
      @dg.transitive_closure,
      @dg.transitive_closure.transitive_closure
    )

    # Compute for a graph containing vertices without edges.
    assert_equal(@dg_loner_tc, @dg_loner.transitive_closure)

    # Iterative applications of transitive closure should return the same result
    # as a single application.
    assert_equal(
      @dg_loner.transitive_closure,
      @dg_loner.transitive_closure.transitive_closure
    )

    # Compute for a graph with cycles.
    assert_equal(@dg_cyclic_tc, @dg_cyclic.transitive_closure)

    # Iterative applications of transitive closure should return the same result
    # as a single application.
    assert_equal(
      @dg_cyclic.transitive_closure,
      @dg_cyclic.transitive_closure.transitive_closure
    )
  end

  def test_transitive_closure_undirected
    assert_raises(NotDirectedError) {AdjacencyGraph.new.transitive_closure}
  end

  def test_transitive_reduction
    # A simple graph without cycles.
    assert_equal(@dg_tr, @dg.transitive_reduction)

    # Compute for a graph containing vertices without edges.
    assert_equal(@dg_loner_tr, @dg_loner.transitive_reduction)

    # Compute for a graph with cycles.
    assert_equal(@dg_cyclic_tr, @dg_cyclic.transitive_reduction)

    # Test that the transitive closure of a transitive reduction is the same as
    # the transitive closure of the original graph.
    assert_equal(
      @dg.transitive_closure,
      @dg.transitive_reduction.transitive_closure
    )
    assert_equal(
      @dg_loner.transitive_closure,
      @dg_loner.transitive_reduction.transitive_closure
    )
    assert_equal(
      @dg_cyclic.transitive_closure,
      @dg_cyclic.transitive_reduction.transitive_closure
    )
  end

  def test_transitive_reduction_undirected
    assert_raises(NotDirectedError) {AdjacencyGraph.new.transitive_reduction}
  end
end

