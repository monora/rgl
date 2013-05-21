require 'test_helper'

require 'rgl/edmonds_karp'
require 'rgl/adjacency'

include RGL

class TestEdmondsKarp < Test::Unit::TestCase

  def setup
    @capacities_map = {
        [1, 2] => 3,
        [1, 4] => 3,
        [2, 3] => 4,
        [3, 1] => 3,
        [3, 4] => 1,
        [3, 5] => 2,
        [4, 5] => 2,
        [4, 6] => 6,
        [5, 2] => 1,
        [5, 7] => 1,
        [6, 7] => 9
    }

    @graph = DirectedAdjacencyGraph[*@capacities_map.keys.flatten]

    add_reverse_edges(@graph, @capacities_map)

    @expected_flow = {
        [1, 2] => 2, [2, 1] => -2,
        [1, 4] => 3, [4, 1] => -3,
        [2, 3] => 2, [3, 2] => -2,
        [3, 4] => 1, [4, 3] => -1,
        [3, 5] => 1, [5, 3] => -1,
        [4, 5] => 0, [5, 4] => 0,
        [4, 6] => 4, [6, 4] => -4,
        [5, 7] => 1, [7, 5] => -1,
        [6, 7] => 4, [7, 6] => -4,
    }
  end

  def test_max_flow
    assert_equal(@expected_flow, maximum_flow(1, 7))
  end

  def test_max_flow_with_lambda_capacities_map
    capacities_lambda = lambda { |edge| @capacities_map[edge] }
    assert_equal(@expected_flow, maximum_flow(1, 7), capacities_lambda)
  end

  def test_reverse_edges_validation
    @graph.remove_edge(2, 1)
    assert_raises(ArgumentError, 'reverse edge for (2, 1) is missing') { maximum_flow(1, 7) }
  end

  def test_missing_capacities_validation
    @capacities_map.delete([3, 5])
    assert_raises(ArgumentError, 'capacity for edge (3, 5) is missing') { maximum_flow(1, 7) }
  end

  def test_negative_capacities_validation
    @capacities_map[[5, 2]] = -2
    assert_raises(ArgumentError, 'capacity of edge (5, 2) is negative') { maximum_flow(1, 7) }
  end

  def test_zero_reverse_capacities_validation
    @capacities_map[[7, 5]] = 1
    assert_raises(ArgumentError, 'either (7, 5) or (5, 7) should have 0 capacity') { maximum_flow(1, 7) }
  end

  def test_zero_capacities
    @capacities_map[[1, 5]] = 0
    @capacities_map[[5, 1]] = 0
    assert_equal(@expected_flow, maximum_flow(1, 7))
  end

  def test_equal_source_and_sink
    assert_raises(ArgumentError, "source and sink can't be equal") { maximum_flow(1, 1) }
  end

  def test_directed_graph_validation
    graph = AdjacencyGraph.new
    graph.add_vertex(1)

    assert_raises(NotDirectedError, 'Edmonds-Karp algorithm can only be applied to a directed graph') { graph.maximum_flow({}, 1, 2) }
  end

  def test_unreachable_sink
    assert_equal({}, maximum_flow(1, 8))
  end

  private

  def maximum_flow(source, sink, capacities_map = @capacities_map)
    @graph.maximum_flow(capacities_map, source, sink)
  end

  def add_reverse_edges(graph, capacities_map)
    capacities_map.keys.each do |(u, v)|
      graph.add_edge(v, u)
      capacities_map[[v, u]] = 0
    end
  end

end
