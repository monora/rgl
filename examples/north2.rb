require 'rgl/graphxml'
require 'rgl/adjacency'
require 'rgl/dot'

include RGL
name,nnodes,nedges = '','',''
IO.foreach('north/Graph.log') {
  |line|
  if /name:\s*(.*)\sformat: graphml\s+nodes: (\d+)\s+edges: (\d+)/ =~ line
	name,nnodes,nedges = $1,$2.to_i,$3.to_i
  end
  if name && /directed: (.*)\s+acyclic: (.*)\s+.*connected: (.*)\s+biconnected: (.*)\s+/ =~ line
	directed, acyclic, connected, biconnected = $1,$2,$3,$4
	puts [name,nnodes,nedges].join('-|-')
	File.open('north/' + name + '.graphml') {
	  |file|
	  graph = DirectedAdjacencyGraph.from_graphxml(file)
	  puts "#{graph.num_vertices} = #{nnodes}"
	}
  end
}
