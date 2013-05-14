require 'test_helper'

require 'rgl/prim'
require 'rgl/adjacency'

include RGL

class TestPrim < Test::Unit::TestCase

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

  def test_minimum_spanning_tree
    assert(minimum_spanning_tree.is_a?(AdjacencyGraph))
  end

  def test_minimum_spanning_tree_edges
    assert_equal([[1, 3], [2, 3], [2, 4]], minimum_spanning_tree_edges)
  end

  def test_minimum_spanning_tree_for_disconnected_graph
    @graph.add_edge(5, 6)
    @graph.add_edge(6, 7)
    @edge_weights.merge!([5, 6] => 1, [6, 7] => 2)

    assert_equal([[1, 3], [2, 3], [2, 4]], minimum_spanning_tree_edges(@edge_weights, 1))
    assert_equal([[5, 6], [6, 7]], minimum_spanning_tree_edges(@edge_weights, 5))
  end

  def test_visitor
    visitor = DijkstraVisitor.new(@graph)

    events = []

    %w[examine_vertex examine_edge edge_relaxed edge_not_relaxed finish_vertex].each do |event|
      visitor.send("set_#{event}_event_handler") { |*args| events << { event.to_sym => args } }
    end

    @graph.prim_minimum_spanning_tree(@edge_weights, 1, visitor)

    assert_equal(
        [
            { :examine_vertex => [1] },
            { :examine_edge   => [1, 2] },
            { :edge_relaxed   => [1, 2] },
            { :examine_edge   => [1, 3] },
            { :edge_relaxed   => [1, 3] },
            { :finish_vertex  => [1] },
            { :examine_vertex => [3] },
            { :examine_edge   => [3, 2] },
            { :edge_relaxed   => [3, 2] },
            { :examine_edge   => [3, 4] },
            { :edge_relaxed   => [3, 4] },
            { :finish_vertex  => [3] },
            { :examine_vertex => [2] },
            { :examine_edge   => [2, 4] },
            { :edge_relaxed   => [2, 4] },
            { :finish_vertex  => [2] },
            { :examine_vertex => [4] },
            { :finish_vertex  => [4] },
        ],
        events
    )
  end

  def test_negative_weights
    @edge_weights[[1, 3]] = -2
    @edge_weights[[2, 3]] = -2

    assert_equal([[1, 3], [2, 3], [2, 4]], minimum_spanning_tree_edges)
  end

  private

  def minimum_spanning_tree_edges(edge_weights = @edge_weights, start_vertex = nil)
    sorted_edges(@graph.prim_minimum_spanning_tree(edge_weights, start_vertex))
  end

  def minimum_spanning_tree(edge_weights = @edge_weights)
    @graph.prim_minimum_spanning_tree(edge_weights)
  end

  def sorted_edges(graph)
    graph.edges.map { |e| [e.source, e.target].sort }.sort
  end

end