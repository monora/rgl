require 'test/unit'
require 'rgl/adjacency'

include RGL
include RGL::Edge

class TestDirectedGraph < Test::Unit::TestCase
  def setup
    @dg = DirectedAdjacencyGraph.new
    [[1,2],[2,3],[3,2],[2,4]].each do |(src,target)| 
      @dg.add_edge(src, target)
    end
  end
  
  def test_empty_graph
    dg = DirectedAdjacencyGraph.new
    assert dg.empty?
    assert dg.directed?
    assert(!dg.has_edge?(2,1))
    assert(!dg.has_vertex?(3))
    # Non existend vertex result in a Name Error because each_key is
    # called for nil
    assert_raises(NoVertexError) {dg.out_degree(3)}
    assert_equal([],dg.vertices)
    assert_equal(0,dg.size)
    assert_equal(0,dg.num_vertices)
    assert_equal(0,dg.num_edges)
    assert_equal(DirectedEdge,dg.edge_class)
    assert([].eql?(dg.edges))
  end
  
  def test_add
    dg = DirectedAdjacencyGraph.new
    dg.add_edge(1,2)
    assert(!dg.empty?)
    assert(dg.has_edge?(1,2))
    assert(!dg.has_edge?(2,1))
    assert(dg.has_vertex?(1) && dg.has_vertex?(2))
    assert(!dg.has_vertex?(3))
    
    assert_equal([1,2],dg.vertices.sort)
    assert([DirectedEdge.new(1,2)].eql?(dg.edges))
    assert_equal("(1-2)",dg.edges.join)
    
    assert_equal([2],dg.adjacent_vertices(1))
    assert_equal([],dg.adjacent_vertices(2))
    
    assert_equal(1,dg.out_degree(1))
    assert_equal(0,dg.out_degree(2))
  end
  
  def test_edges
    assert_equal(4, @dg.edges.length)
    assert_equal([1,2,2,3], @dg.edges.map {|l| l.source}.sort)
    assert_equal([2,2,3,4], @dg.edges.map {|l| l.target}.sort)
    assert_equal("(1-2)(2-3)(2-4)(3-2)", @dg.edges.map {|l| l.to_s}.sort.join)
    #    assert_equal([0,1,2,3], @dg.edges.map {|l| l.info}.sort)
  end
  
  def test_vertices
    assert_equal([1,2,3,4], @dg.vertices.sort)
  end
  
  def test_edges_from_to?
    assert @dg.has_edge?(1,2)
    assert @dg.has_edge?(2,3)
    assert @dg.has_edge?(3,2)
    assert @dg.has_edge?(2,4)
    assert !@dg.has_edge?(2,1)
    assert !@dg.has_edge?(3,1)
    assert !@dg.has_edge?(4,1)
    assert !@dg.has_edge?(4,2)
  end
  
  def test_remove_edges
    @dg.remove_edge 1,2
    assert !@dg.has_edge?(1,2)
    @dg.remove_edge 1,2
    assert !@dg.has_edge?(1,2)
    @dg.remove_vertex 3
    assert !@dg.has_vertex?(3)
    assert !@dg.has_edge?(2,3)
    assert_equal('(2-4)',@dg.edges.join)
  end
  
  def test_add_vertices
    dg = DirectedAdjacencyGraph.new
    dg.add_vertices 1,3,2,4
    assert_equal dg.vertices.sort, [1,2,3,4]
    
    dg.remove_vertices 1,3
    assert_equal dg.vertices.sort, [2,4]
  end
  
  def test_creating_from_array
    dg = DirectedAdjacencyGraph[1, 2, 3, 4]
    assert_equal([1,2,3,4], dg.vertices.sort)
    assert_equal('(1-2)(3-4)', dg.edges.join)
  end
  
  def test_reverse
    reverted = @dg.reverse
    @dg.each_edge do |u,v|
      assert(reverted.has_edge?(v,u))
    end
  end
  
  def test_reverse
    # Add isolated vertex
    @dg.add_vertex(42)
    reverted = @dg.reverse
    
    @dg.each_edge do |u,v|
      assert(reverted.has_edge?(v,u))
    end
    
    assert(reverted.has_vertex?(42),
           'Reverted graph should contain isolated Vertex 42')
  end
  
  def test_to_undirected
    undirected = @dg.to_undirected
    assert_equal '(1=2)(2=3)(2=4)', undirected.edges.sort.join
  end
end
