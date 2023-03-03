require 'test_helper'

require 'rgl/bidirectional_adjacency'
require 'directed_graph_test'

include RGL
include RGL::Edge

class TestBidirectionalAdjacencyGraph < Test::Unit::TestCase
  def setup
    @edges = [[1, 2], [1, 3], [2, 3], [2, 4], [2, 5], [2, 6], [3, 2], [3, 7], [3, 8],
             [5, 10], [6, 9], [7, 9], [7, 10], [8, 10]]
    @out_neighbors = Hash.new { |h, k| h[k] = Set.new }
    @in_neighbors = Hash.new { |h, k| h[k] = Set.new }
    @edges.each do |e|
      @out_neighbors[e[0]] << e[1]
      @in_neighbors[e[1]] << e[0]
    end
    @dg = BidirectionalAdjacencyGraph.new
    @edges.each do |(src, target)|
      @dg.add_edge(src, target)
    end
    @eg = BidirectionalAdjacencyGraph.new
    @gfa = BidirectionalAdjacencyGraph[1, 2, 3, 4]
  end

  def test_empty_graph
    assert @eg.empty?
    assert @eg.directed?
    assert(!@eg.has_edge?(2, 1))
    assert(!@eg.has_out_edge?(2, 1))
    assert(!@eg.has_in_edge?(1, 2))
    assert(!@eg.has_vertex?(3))
    # Non existent vertex result in a Name Error because each_key is
    # called for nil
    assert_raises(NoVertexError) { @eg.out_degree(3) }
    assert_raises(NoVertexError) { @eg.in_degree(3) }
    assert_equal([], @eg.vertices)
    assert_equal(0, @eg.size)
    assert_equal(0, @eg.num_vertices)
    assert_equal(0, @eg.num_edges)
    assert_equal(DirectedEdge, @eg.edge_class)
    assert_empty(@eg.edges)
  end

  def test_add
    @eg.add_edge(1, 2)
    assert(!@eg.empty?)
    assert(@eg.has_edge?(1, 2))
    assert(@eg.has_out_edge?(1, 2))
    assert(@eg.has_in_edge?(2, 1))
    assert(!@eg.has_edge?(2, 1))
    assert(!@eg.has_out_edge?(2, 1))
    assert(!@eg.has_in_edge?(1, 2))
    assert(@eg.has_vertex?(1) && @eg.has_vertex?(2))
    assert(!@eg.has_vertex?(3))

    assert_equal([1, 2], @eg.vertices.sort)
    assert([DirectedEdge.new(1, 2)].eql?(@eg.edges))
    assert_equal("(1-2)", @eg.edges.join)

    assert_equal([2], @eg.adjacent_vertices(1))
    assert_equal([2], @eg.out_neighbors(1))
    assert_equal([], @eg.in_neighbors(1))
    assert_equal([], @eg.adjacent_vertices(2))
    assert_equal([], @eg.out_neighbors(2))
    assert_equal([1], @eg.in_neighbors(2))

    assert_equal(1, @eg.out_degree(1))
    assert_equal(0, @eg.in_degree(1))
    assert_equal(0, @eg.out_degree(2))
    assert_equal(1, @eg.in_degree(2))
  end

  def test_edges
    assert_equal(14, @dg.edges.length)
    assert_equal(@edges.map { |e| e[0] }.to_set, @dg.edges.map { |l| l.source }.to_set)
    assert_equal(@edges.map { |e| e[1] }.to_set, @dg.edges.map { |l| l.target }.to_set)
    assert_equal("(1-2)(1-3)(2-3)(2-4)(2-5)(2-6)(3-2)(3-7)(3-8)(5-10)(6-9)(7-10)(7-9)(8-10)", @dg.edges.map { |l| l.to_s }.sort.join)
  end

  def test_vertices
    assert_equal(@edges.flatten.to_set, @dg.vertices.to_set)
  end

  def test_edges_from_to?
    @edges.each do |u, v|
      assert @dg.has_edge?(u, v)
      assert @dg.has_out_edge?(u, v)
      assert @dg.has_in_edge?(v, u)
    end
  end

  def test_remove_edges
    @dg.remove_edge 1, 2
    assert !@dg.has_edge?(1, 2)
    assert !@dg.has_out_edge?(1, 2)
    assert !@dg.has_in_edge?(2, 1)
    @dg.remove_edge 1, 2
    assert !@dg.has_edge?(1, 2)
    assert !@dg.has_out_edge?(1, 2)
    assert !@dg.has_in_edge?(2, 1)
    @dg.remove_vertex 3
    assert !@dg.has_vertex?(3)
    assert !@dg.has_edge?(2, 3)
    assert !@dg.has_out_edge?(2, 3)
    assert !@dg.has_in_edge?(3, 2)
    assert_equal('(2-4)(2-5)(2-6)(5-10)(6-9)(7-9)(7-10)(8-10)', @dg.edges.join)
  end

  def test_add_vertices
    @eg.add_vertices 1, 3, 2, 4
    assert_equal @eg.vertices.sort, [1, 2, 3, 4]

    @eg.remove_vertices 1, 3
    assert_equal @eg.vertices.sort, [2, 4]
  end

  def test_creating_from_array
    assert_equal([1, 2, 3, 4], @gfa.vertices.sort)
    assert_equal('(1-2)(3-4)', @gfa.edges.join)
  end

  def test_creating_from_graphs
    dg2 = BidirectionalAdjacencyGraph.new(Set, @dg, @gfa)
    assert_equal(dg2.vertices.to_set, (@dg.vertices + @gfa.vertices).to_set)
    assert_equal(dg2.edges.to_set, (@dg.edges + @gfa.edges).to_set)
  end

  def test_reverse
    # Add isolated vertex
    @dg.add_vertex(42)
    reverted = @dg.reverse

    @dg.each_edge do |u, v|
      assert(reverted.has_edge?(v, u))
    end

    assert(reverted.has_vertex?(42), 'Reverted graph should contain isolated Vertex 42')
  end

  def test_to_undirected
    undirected = @dg.to_undirected
    assert_equal '(1=2)(1=3)(2=3)(2=4)(2=5)(2=6)(3=7)(3=8)(5=10)(6=9)(7=9)(7=10)(8=10)', undirected.edges.sort.join
  end

  def test_neighbors
    @edges.flatten.to_set.each do |v|
      assert_equal @out_neighbors[v], @dg.out_neighbors(v).to_set
      assert_equal @in_neighbors[v], @dg.in_neighbors(v).to_set
    end
  end

  def test_each_neighbor
    @edges.flatten.to_set.each do |v|
      out_neighbors = Set.new
      @dg.each_out_neighbor(v) { |n| out_neighbors << n }
      assert_equal @out_neighbors[v], out_neighbors
      in_neighbors = Set.new
      @dg.each_in_neighbor(v) { |n| in_neighbors << n }
      assert_equal @in_neighbors[v], in_neighbors
    end
  end

  def test_degrees
    @edges.flatten.to_set.each do |v|
      assert_equal @out_neighbors[v].size, @dg.out_degree(v)
      assert_equal @in_neighbors[v].size, @dg.in_degree(v)
      assert_equal @out_neighbors[v].size + @in_neighbors[v].size, @dg.degree(v)
    end
  end

end
