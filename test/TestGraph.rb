require 'test/unit'
require 'rgl/adjacency'
require 'test_helper'

include RGL

class TestGraph < Test::Unit::TestCase

  class NotImplementedGraph
    include Graph
  end

  def setup
    @dg1 = DirectedAdjacencyGraph.new
    @edges = [[1,2],[2,3],[2,4],[4,5],[1,6],[6,4]]
    @edges.each do |(src,target)|
      @dg1.add_edge(src, target)
    end
    @loan_vertices = [7, 8, 9]
    @loan_vertices.each do |vertex|
      @dg1.add_vertex(vertex)
    end

    @dg2 = DirectedAdjacencyGraph[*@edges.flatten]
    @loan_vertices.each do |vertex|
      @dg2.add_vertex(vertex)
    end

    @ug = AdjacencyGraph.new(Array)
    @ug.add_edges(*@edges)
    @ug.add_vertices(*@loan_vertices)
  end

  def test_equality
    assert_equal @dg1, @dg1
    assert_equal @dg1, @dg1.dup
    assert_equal @ug, @ug.dup
    assert_not_equal @ug, @dg1
    assert_not_equal @dg1, @ug
    assert_not_equal @dg1, 42
    assert_equal @dg1, @dg2
    @dg1.add_vertex 42
    assert_not_equal @dg1, @dg2
  end

  def test_to_adjacency
    assert_equal @dg1, @dg1.to_adjacency
    assert_equal @ug, @ug.to_adjacency
  end

  def test_merge
    merge = DirectedAdjacencyGraph.new(Array, @dg1, @ug)
    assert_equal merge.num_edges, 12
    assert_equal merge.num_vertices, 9
    merge = DirectedAdjacencyGraph.new(Set, @dg1, @dg1)
    assert_equal merge.num_edges, 6
    assert_equal merge.num_vertices, 9
  end

  def test_set_edgelist_class
    edges = @dg1.edges
    @dg1.edgelist_class=Array
    assert_equal edges, @dg1.edges
  end

  def test_not_implemented
    graph = NotImplementedGraph.new
    assert_raise(NotImplementedError) { graph.each_vertex }
    assert_raise(NotImplementedError) { graph.each_adjacent(nil) }
  end
end
