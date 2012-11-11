require 'test/unit'
require 'rgl/implicit'
require 'rgl/adjacency'

include RGL

class TestImplicit < Test::Unit::TestCase
  def setup
    @dg = DirectedAdjacencyGraph.new
    [[1,2],[2,3],[2,4],[4,5],[1,6],[6,4]].each do |(src,target)| 
      @dg.add_edge(src, target)
    end

	@cycle = ImplicitGraph.new { |g|
	  g.vertex_iterator { |b| 0.upto(4,&b) }
	  g.adjacent_iterator { |x, b| b.call((x+1)%5) }
	  g.directed = true
	}
  end

  def test_empty
	empty = ImplicitGraph.new
	assert(empty.empty?)
	assert_equal([],empty.edges)
	assert_equal([],empty.vertices)
  end

  def test_cycle
	assert(!@cycle.empty?)
	assert_equal([0, 1, 2, 3, 4],@cycle.vertices.sort)
	assert_equal("(0-1)(1-2)(2-3)(3-4)(4-0)",@cycle.edges.sort.join)
  end
  
  def test_vertex_filtered_graph
	fg = @cycle.vertices_filtered_by {|v| v%2 == 0}
	assert_equal([0, 2, 4],fg.vertices.sort)
	assert_equal("(4-0)",fg.edges.sort.join)
	assert(fg.directed?)

	fg = @dg.vertices_filtered_by {|v| v%2 == 0}
	assert_equal([2, 4, 6],fg.vertices.sort)
	assert_equal("(2-4)(6-4)",fg.edges.sort.join)
	assert(fg.directed?)
  end

  def test_edge_filtered_graph
	fg = @cycle.edges_filtered_by {|u,v| u+v > 3}
	assert_equal(@cycle.vertices.sort,fg.vertices.sort)
	assert_equal("(2-3)(3-4)(4-0)",fg.edges.sort.join)
	assert(fg.directed?)
  end
end
