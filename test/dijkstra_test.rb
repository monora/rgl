require 'test_helper'

require 'rgl/dijkstra'
require 'rgl/adjacency'

include RGL

class TestDijkstra < Test::Unit::TestCase

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

  def test_shortest_path_search
    assert_equal([1, 3, 2, 4], shortest_path(1, 4))
  end

  def test_shortest_path_search_with_lambda
    assert_equal([1, 3, 2, 4], shortest_path(1, 4, @edge_weights_lambda))
  end

  def test_shortest_path_to_the_source
    assert_equal([1], shortest_path(1, 1))
  end

  def test_path_for_unreachable_vertex
    @graph.add_vertex(5)
    assert_equal(nil, shortest_path(1, 5))
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

  def test_visitor
    visitor = DijkstraVisitor.new(@graph)

    events = []

    %w[examine_vertex examine_edge edge_relaxed edge_not_relaxed finish_vertex].each do |event|
      visitor.send("set_#{event}_event_handler") { |*args| events << { event.to_sym => args } }
    end

    @graph.dijkstra_shortest_paths(@edge_weights, 1, visitor)

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

  def test_negative_edge_weight
    @edge_weights[[2, 3]] = -7
    assert_raises(ArgumentError, 'weight of edge (2, 3) is negative') { shortest_path(1, 5) }
  end

  def test_negative_edge_weight_with_lambda
    @edge_weights[[2, 3]] = -7
    assert_raises(ArgumentError, 'weight of edge (2, 3) is negative') { shortest_path(1, 5, @edge_weights_lambda) }
  end

  def test_missing_edge_weight
    @edge_weights.delete([2, 3])
    assert_raises(ArgumentError, 'weight of edge (2, 3) is not defined') { shortest_path(1, 5) }
  end

  def test_edge_weights_map_object_in_argument
    weights_map = EdgePropertiesMap.new(@edge_weights, @graph.directed?)
    dijkstra    = DijkstraAlgorithm.new(@graph, weights_map, DijkstraVisitor.new(@graph))

    assert_equal([1, 3, 2, 4], dijkstra.shortest_path(1, 4))
  end

  private

  def shortest_path(source, target, edge_weights = @edge_weights)
    @graph.dijkstra_shortest_path(edge_weights, source, target)
  end

  def shortest_paths(source, edge_weights = @edge_weights)
    @graph.dijkstra_shortest_paths(edge_weights, source)
  end

end