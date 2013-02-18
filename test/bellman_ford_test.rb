require 'test_helper'

require 'rgl/bellman_ford'
require 'rgl/adjacency'

include RGL

class TestBellmanFord < Test::Unit::TestCase

  def setup
    @graph = AdjacencyGraph[1,2, 1,3, 2,3, 2,4, 3,4]

    @edge_weights = {
        [1, 2] => 10,
        [1, 3] => 1,
        [2, 3] => 1,
        [2, 4] => 1,
        [3, 4] => 10
    }

    @edge_weights_lambda = lambda { |edge| @edge_weights[edge] }
  end

  def test_shortest_paths_search
    assert_equal(
        {
            1 => [1],
            2 => [1, 3, 2],
            3 => [1, 3],
            4 => [1, 3, 2, 4]
        },
        shortest_paths(1)
    )
  end

  def test_shortest_paths_search_with_lambda
    assert_equal(
        {
            1 => [1],
            2 => [1, 3, 2],
            3 => [1, 3],
            4 => [1, 3, 2, 4]
        },
        shortest_paths(1, @edge_weights_lambda)
    )
  end

  def test_shortest_paths_search_with_unreachable_vertex
    @graph.add_vertex(5)

    assert_equal(
        {
            1 => [1],
            2 => [1, 3, 2],
            3 => [1, 3],
            4 => [1, 3, 2, 4],
            5 => nil
        },
        shortest_paths(1)
    )
  end

  def test_shortest_paths_with_negative_weights
    # can't use an undirected graph with a negative weighted edge here, because a negative weighted undirected edge is
    # already a negative weighted cycle and therefore Bellman-Ford can't be applied for such graph
    @graph = DirectedAdjacencyGraph[1,2, 1,3, 2,3, 2,4, 3,2, 3,4]
    @edge_weights[[3, 2]] = 1
    @edge_weights[[3, 4]] = -1

    assert_equal(
        {
            1 => [1],
            2 => [1, 3, 2],
            3 => [1, 3],
            4 => [1, 3, 4]
        },
        shortest_paths(1)
    )
  end

  def test_missing_edge_weight
    @edge_weights.delete([2, 3])
    assert_raises(ArgumentError, 'weight of edge (2, 3) is not defined') { shortest_paths(1) }
  end

  def test_negative_cycles
    @graph = DirectedAdjacencyGraph[1,2, 1,3, 2,3, 2,4, 3,4, 4,2]
    @edge_weights[[4, 2]] = 1
    @edge_weights[[3, 4]] = -3 # cycle 2-3-4-2 has negative weight

    assert_raises(ArgumentError, 'there is a negative-weight cycle including edge (3, 4)') { shortest_paths(1) }
  end

  def test_visitor
    visitor = BellmanFordVisitor.new(@graph)

    events = []

    %w[examine_edge edge_relaxed edge_not_relaxed edge_minimized edge_not_minimized].each do |event|
      visitor.send("set_#{event}_event_handler") { |*args| events << { event.to_sym => args } }
    end

    @graph.bellman_ford_shortest_paths(@edge_weights, 1, visitor)

    assert_equal(
        [
            # first iteration
            { :examine_edge     => [1, 2] },
            { :edge_relaxed     => [1, 2] },
            { :examine_edge     => [2, 1] },
            { :edge_not_relaxed => [2, 1] },
            { :examine_edge     => [1, 3] },
            { :edge_relaxed     => [1, 3] },
            { :examine_edge     => [3, 1] },
            { :edge_not_relaxed => [3, 1] },
            { :examine_edge     => [2, 3] },
            { :edge_not_relaxed => [2, 3] },
            { :examine_edge     => [3, 2] },
            { :edge_relaxed     => [3, 2] },
            { :examine_edge     => [2, 4] },
            { :edge_relaxed     => [2, 4] },
            { :examine_edge     => [4, 2] },
            { :edge_not_relaxed => [4, 2] },
            { :examine_edge     => [3, 4] },
            { :edge_not_relaxed => [3, 4] },
            { :examine_edge     => [4, 3] },
            { :edge_not_relaxed => [4, 3] },
            # second iteration
            { :examine_edge     => [1, 2] },
            { :edge_not_relaxed => [1, 2] },
            { :examine_edge     => [2, 1] },
            { :edge_not_relaxed => [2, 1] },
            { :examine_edge     => [1, 3] },
            { :edge_not_relaxed => [1, 3] },
            { :examine_edge     => [3, 1] },
            { :edge_not_relaxed => [3, 1] },
            { :examine_edge     => [2, 3] },
            { :edge_not_relaxed => [2, 3] },
            { :examine_edge     => [3, 2] },
            { :edge_not_relaxed => [3, 2] },
            { :examine_edge     => [2, 4] },
            { :edge_not_relaxed => [2, 4] },
            { :examine_edge     => [4, 2] },
            { :edge_not_relaxed => [4, 2] },
            { :examine_edge     => [3, 4] },
            { :edge_not_relaxed => [3, 4] },
            { :examine_edge     => [4, 3] },
            { :edge_not_relaxed => [4, 3] },
            # thirds iteration
            { :examine_edge     => [1, 2] },
            { :edge_not_relaxed => [1, 2] },
            { :examine_edge     => [2, 1] },
            { :edge_not_relaxed => [2, 1] },
            { :examine_edge     => [1, 3] },
            { :edge_not_relaxed => [1, 3] },
            { :examine_edge     => [3, 1] },
            { :edge_not_relaxed => [3, 1] },
            { :examine_edge     => [2, 3] },
            { :edge_not_relaxed => [2, 3] },
            { :examine_edge     => [3, 2] },
            { :edge_not_relaxed => [3, 2] },
            { :examine_edge     => [2, 4] },
            { :edge_not_relaxed => [2, 4] },
            { :examine_edge     => [4, 2] },
            { :edge_not_relaxed => [4, 2] },
            { :examine_edge     => [3, 4] },
            { :edge_not_relaxed => [3, 4] },
            { :examine_edge     => [4, 3] },
            { :edge_not_relaxed => [4, 3] },
            # post-iteration check
            { :edge_minimized   => [1, 2] },
            { :edge_minimized   => [1, 3] },
            { :edge_minimized   => [2, 3] },
            { :edge_minimized   => [2, 4] },
            { :edge_minimized   => [3, 4] }
        ],
        events
    )
  end

  private

  def shortest_paths(source, edge_weights = @edge_weights)
    @graph.bellman_ford_shortest_paths(edge_weights, source)
  end

end