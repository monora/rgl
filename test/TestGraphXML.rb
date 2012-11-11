require 'test/unit'
require 'rgl/graphxml'
require 'rgl/adjacency'
require 'rgl/topsort'
require 'rgl/connected_components'
require 'rgl/dot'

include RGL

class TestGraphXML < Test::Unit::TestCase
  NORTH_DIR = './examples/north/'

  def setup
    @stream = File.new(NORTH_DIR + "g.10.0.graphml")
  end

  def tear_down
	@stream.close
  end

  def test_graphxml
	@dg = DirectedAdjacencyGraph.new.from_graphxml(@stream).edges.sort.join
	assert_equal("(n0-n1)(n0-n2)(n0-n9)(n3-n4)(n4-n5)(n5-n7)(n8-n0)(n8-n3)(n8-n4)(n8-n5)(n8-n6)",@dg)
  end

  def test_north_graphs
	name,nnodes,nedges = '',0,0
	IO.foreach(NORTH_DIR + '/Graph.log') {
	  |line|
	  if /name:\s*(.*)\sformat: graphml\s+nodes: (\d+)\s+edges: (\d+)/ =~ line
		name,nnodes,nedges = $1,$2.to_i,$3.to_i
	  end
	  if name && /directed: (\w+).*acyclic: (\w+).*connected: (\w+).*biconnected: (\w+)\s+/ =~ line
		directed, acyclic, connected, biconnected = $1,$2,$3,$4
		File.open(NORTH_DIR + name + '.graphml') {
		  |file|
		  print '.'; $stdout.flush
		  graph = (directed == 'true' ? DirectedAdjacencyGraph : AdjacencyGraph).new.from_graphxml(file)
		  #graph.write_to_graphic_file
		  assert_equal(nnodes,graph.num_vertices)
		  assert_equal(nedges,graph.num_edges)
		  assert_equal(acyclic,graph.acyclic?.to_s)

		  num_comp = 0
		  graph.to_undirected.each_connected_component {|x| num_comp += 1}
		  assert_equal(connected,(num_comp == 1).to_s)

# 		  if graph.directed?
# 			num_comp = graph.strongly_connected_components.num_comp
# 			#puts num_comp
# 			assert_equal(biconnected, (num_comp == 1).to_s)
# 		  end
		}
	  end
	}
  end
end
