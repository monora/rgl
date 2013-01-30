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
  end

  def test_shortest_path_search
    assert_equal([1, 3, 2, 4], shortest_path(1, 4))
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

  private

  def shortest_path(source, target)
    @graph.dijkstra_shortest_path(@edge_weights, source, target)
  end

  def shortest_paths(source)
    @graph.dijkstra_shortest_paths(@edge_weights, source)
  end

end