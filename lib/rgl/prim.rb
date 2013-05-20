require 'rgl/dijkstra'
require 'rgl/adjacency'

module RGL

  class PrimAlgorithm

    # Replacement for default distance combinator that is used in Dijkstra's algorithm. While building a minimum
    # spanning tree (MST) we're interested not in the distance from the source (the vertex that is added first to the
    # MST) to a vertex, but rather in the distance between already completed part of the MST (that includes all examined
    # vertices) and the vertex. Therefore, when we examine an edge (u, v), where _u_ is already in the MST and _v_ is
    # not, the distance from the MST to the vertex _v_ is the weight of the edge (u, v).
    DISTANCE_COMBINATOR = lambda { |_, edge_weight| edge_weight }

    # Initializes Prim's algorithm for a _graph_ with provided edges weights map.
    #
    def initialize(graph, edge_weights_map, visitor)
      @graph            = graph
      @edge_weights_map = EdgePropertiesMap.new(edge_weights_map, @graph.directed?)
      @visitor          = visitor
      @dijkstra         = DijkstraAlgorithm.new(@graph, @edge_weights_map, @visitor, DISTANCE_COMBINATOR)
    end

    # Returns minimum spanning tree for the _graph_. If the graph is disconnected, Prim's algorithm will find the minimum
    # spanning tree only for one of the connectivity components. If _start_vertex_ is given, Dijkstra's search will be
    # started in this vertex and the algorithm will return the minimum spanning tree for the component it belongs to.
    #
    def minimum_spanning_tree(start_vertex = nil)
      @dijkstra.find_shortest_paths(start_vertex || @graph.vertices.first)
      AdjacencyGraph[*@visitor.parents_map.to_a.flatten]
    end

  end # class PrimAlgorithm

  module Graph

    # Finds the minimum spanning tree of the graph.
    #
    # Returns an AdjacencyGraph that represents the minimum spanning tree of the graph's connectivity component that
    # contains the starting vertex. The algorithm starts from an arbitrary vertex if the _start_vertex_ is not given.
    # Since the implementation relies on the Dijkstra's algorithm, Prim's algorithm uses the same visitor class and emits
    # the same events.
    #
    # Raises ArgumentError if edge weight is undefined.
    #
    def prim_minimum_spanning_tree(edge_weights_map, start_vertex = nil, visitor = DijkstraVisitor.new(self))
      PrimAlgorithm.new(self, edge_weights_map, visitor).minimum_spanning_tree(start_vertex)
    end

  end # module Graph

end # module RGL
