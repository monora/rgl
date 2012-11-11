require 'test/unit'
require 'rgl/adjacency'
require 'rgl/traversal'
require 'rgl/topsort'
require 'rgl/implicit'

require 'test_helper'

include RGL

class TestTraversal < Test::Unit::TestCase

  def setup
    @dg = DirectedAdjacencyGraph.new(Array)
	edges = [[1,2],[2,3],[2,4],[4,5],[1,6],[6,4]]
    edges.each do |(src,target)| 
      @dg.add_edge(src, target)
    end
	@bfs = @dg.bfs_iterator(1)
	@dfs = @dg.dfs_iterator(1)

	@ug = AdjacencyGraph.new(Array)
	@ug.add_edges(*edges)
  end

  def test_bfs_iterator_creation
	assert(@bfs.at_beginning?)
	assert(!@bfs.at_end?)
	assert_equal(1,@bfs.start_vertex)
	assert_equal(@dg,@bfs.graph)
  end

  def test_bfs_visiting
	expected = [1, 2, 6, 3, 4, 5]
  	assert_equal(expected,@bfs.to_a)
  	assert_equal(expected,@ug.bfs_iterator(1).to_a)
  	assert_equal([2, 1, 3, 4, 6, 5],@ug.bfs_iterator(2).to_a)
  end

  def test_bfs_event_handlers
	expected = 
'tree_edge      : -1
examine_vertex : 1
examine_edge   : 1-2
tree_edge      : 1-2
examine_edge   : 1-6
tree_edge      : 1-6
finished_vertex: 1
examine_vertex : 2
examine_edge   : 2-3
tree_edge      : 2-3
examine_edge   : 2-4
tree_edge      : 2-4
finished_vertex: 2
examine_vertex : 6
examine_edge   : 6-4
back_edge      : 6-4
finished_vertex: 6
examine_vertex : 3
finished_vertex: 3
examine_vertex : 4
examine_edge   : 4-5
tree_edge      : 4-5
finished_vertex: 4
examine_vertex : 5
examine_edge   : 5-3
forward_edge   : 5-3
finished_vertex: 5
'
	s = ''
	@dg.add_edge 5,3			# for the forward_edge 5-3
	@bfs.set_examine_vertex_event_handler { |v| s << "examine_vertex : #{v}\n"}
	@bfs.set_examine_edge_event_handler { |u,v| s << "examine_edge   : #{u}-#{v}\n"}
	@bfs.set_tree_edge_event_handler {    |u,v| s << "tree_edge      : #{u}-#{v}\n"}
	@bfs.set_back_edge_event_handler {    |u,v| s << "back_edge      : #{u}-#{v}\n"}
	@bfs.set_forward_edge_event_handler { |u,v| s << "forward_edge   : #{u}-#{v}\n"}

	@bfs.each {|v|						s << "finished_vertex: #{v}\n"}
	puts "BFS: ", s if $DEBUG
  	assert_equal(expected,s)
  end

  def test_dfs_visiting
  	assert_equal([1, 6, 4, 5, 2, 3],@dg.dfs_iterator(1).to_a)
  	assert_equal([2, 4, 5, 3],@dg.dfs_iterator(2).to_a)
  end

  def test_dfs_event_handlers
	expected = 
'tree_edge      : -1
examine_vertex : 1
examine_edge   : 1-2
tree_edge      : 1-2
examine_edge   : 1-6
tree_edge      : 1-6
finished_vertex: 1
examine_vertex : 6
examine_edge   : 6-4
tree_edge      : 6-4
finished_vertex: 6
examine_vertex : 4
examine_edge   : 4-5
tree_edge      : 4-5
finished_vertex: 4
examine_vertex : 5
examine_edge   : 5-3
tree_edge      : 5-3
finished_vertex: 5
examine_vertex : 3
finished_vertex: 3
examine_vertex : 2
examine_edge   : 2-3
forward_edge   : 2-3
examine_edge   : 2-4
forward_edge   : 2-4
finished_vertex: 2
'
	s = ''
	@dg.add_edge 5,3			
	@dfs.set_examine_vertex_event_handler { |v| s << "examine_vertex : #{v}\n"}
	@dfs.set_examine_edge_event_handler { |u,v| s << "examine_edge   : #{u}-#{v}\n"}
	@dfs.set_tree_edge_event_handler {    |u,v| s << "tree_edge      : #{u}-#{v}\n"}
	@dfs.set_back_edge_event_handler {    |u,v| s << "back_edge      : #{u}-#{v}\n"}
	@dfs.set_forward_edge_event_handler { |u,v| s << "forward_edge   : #{u}-#{v}\n"}

	@dfs.each {|v|						s << "finished_vertex: #{v}\n"}
	puts "DFS: ", s if $DEBUG
  	assert_equal(expected,s)
  end

  def test_bfs_search_tree
	assert_equal("(1-2)(1-6)(2-3)(2-4)(4-5)",@dg.bfs_search_tree_from(1).edges.sort.join)
  end
  
  def aux(it)
	it.attach_distance_map
	it.set_to_end
	it.graph.vertices.sort.collect {|v|
	  "#{v}-#{it.distance_to_root(v)}"
	}.join(', ')
  end
  def test_distance_map
	assert_equal("1-0, 2-1, 3-2, 4-2, 5-3, 6-1",aux(@bfs))
	@dg.add_edge 5,3
	assert_equal("1-0, 2-1, 3-4, 4-2, 5-3, 6-1",aux(@dfs))
  end

  def test_topsort
	ts_it = @dg.topsort_iterator
	assert(ts_it.at_beginning?)
	assert_equal(@dg,ts_it.graph)
	assert(!ts_it.at_end?)
	ts_order = ts_it.to_a		# do the traversal
	assert_equal(@dg.num_vertices,ts_order.size)
	
	# Check topsort contraint:
	@dg.each_edge { |u,v|
	  assert(ts_order.index(u) < ts_order.index(v))
	}
	ts_it.set_to_begin
	assert(ts_it.at_beginning?)
	
	# Topsort on undirected graphs is empty
	assert(@ug.topsort_iterator.at_end?)
  end
  
  # depth_first_search can also be used to compute a topsort!
  def test_dfs_search_as_topsort
	ts_order = []
	@dg.depth_first_search { |v| ts_order << v }
	ts_order = ts_order.reverse
	@dg.each_edge { |u,v|
	  assert(ts_order.index(u) < ts_order.index(v))
	}	  
  end

  def test_acyclic
	assert(@dg.acyclic?)
	@dg.add_edge 5,2			# add cycle
	assert(!@dg.acyclic?)
  end

  def test_dfs_visit
	a = []
	@dg.depth_first_visit(1) { |x| a << x }
	assert_equal([3, 5, 4, 2, 6, 1],a)

	a = []
	@dg.add_edge 10,11
	@dg.depth_first_visit(10) { |x| a << x }
	assert_equal([11, 10],a)
  end

  def test_dfs_visit_with_parens
	a = ""
	vis = DFSVisitor.new(@dg)
	vis.set_examine_vertex_event_handler {|v| a << "(#{v} "}
	vis.set_finish_vertex_event_handler {|v| a << " #{v})"}
	@dg.depth_first_visit(1,vis) { |x| }
	assert_equal("(1 (2 (3  3)(4 (5  5) 4) 2)(6  6) 1)",a)
  end

  def test_depth_first_search_with_parens
	@dg.add_edge 10,11
	# We must ensure, that the order of the traversal is not dependend on the
	# order of the each iterator in the hash map of the adjacency graph. Therefor we
	# wrap the graph with an implicit graph that simply ensures a sort order on 
	# the vertices.
	dg = @dg.implicit_graph {
	  | g |
	  g.vertex_iterator { |b| @dg.vertices.sort.each(&b)}
	}
	a = ""
	vis = DFSVisitor.new(dg)
	vis.set_examine_vertex_event_handler {|v| a << "(#{v} "}
	vis.set_finish_vertex_event_handler {|v| a << " #{v})"}
	dg.depth_first_search(vis) { |x| }
	assert_equal("(1 (2 (3  3)(4 (5  5) 4) 2)(6  6) 1)(10 (11  11) 10)",a)
  end
end
