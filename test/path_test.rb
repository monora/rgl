# frozen_string_literal: true

require 'test_helper'

require 'rgl/adjacency'
require 'rgl/path'

class TestPath < Test::Unit::TestCase
  include RGL

  def setup
    edges = [[1, 2], [2, 3], [2, 4], [4, 5], [6, 4], [1, 6]]
    @directed_graph, @undirected_graph =
      [DirectedAdjacencyGraph, AdjacencyGraph].map do |klass|
        graph = klass.new
        graph.add_edges(*edges)
        graph
      end
  end

  def test_path_for_directed_graph
    assert(@directed_graph.path?(1, 5))
  end

  def test_path_for_undirected_graph
    assert(@undirected_graph.path?(1, 5))
  end

  def test_inverse_path_for_directed_graph
    assert_equal(@directed_graph.path?(3, 1), false)
  end

  def test_inverse_path_for_undirected_graph
    assert(@undirected_graph.path?(3, 1))
  end

  def test_path_for_directed_graph_wrong_source
    assert_equal(@directed_graph.path?(0, 1), false)
  end

  def test_path_for_undirected_graph_wrong_source
    assert_equal(@undirected_graph.path?(0, 1), false)
  end

  def test_path_for_directed_graph_wrong_target
    assert_equal(@directed_graph.path?(4, 0), false)
  end

  def test_path_for_undirected_graph_wrong_target
    assert_equal(@undirected_graph.path?(4, 0), false)
  end
end
