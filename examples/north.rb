require 'rgl/graphxml'
require 'rgl/adjacency'
require 'rgl/dot'

include RGL

Dir['north/*.graphml'].each do |filename|
  File.open(filename) { |file|
	graph = DirectedAdjacencyGraph.from_graphxml(file)
	graph.write_to_graphic_file('jpg',filename)
  }
end
