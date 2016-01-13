require 'rgl/dijkstra_visitor'
require 'rgl/edge_properties_map'
require 'rgl/path_builder'

require 'lazy_priority_queue'

module RGL

  # Bellman-Ford shortest paths algorithm has the following event points:
  #
  #  * examine_edge
  #  * edge_relaxed
  #  * edge_not_relaxed
  #  * edge_minimized
  #  * edge_not_minimized
  #
  class BellmanFordVisitor < DijkstraVisitor

    def_event_handlers :edge_minimized, :edge_not_minimized

    def initialize(graph)
      super(graph)

      # by default, through an exception if a negative-weight cycle is detected
      @edge_not_minimized_event_handler = lambda do |u, v|
        raise ArgumentError.new("there is a negative-weight cycle including edge (#{u}, #{v})")
      end
    end

  end

  class BellmanFordAlgorithm

    # Initializes Bellman-Ford algorithm for a _graph_ with provided edges weights map.
    #
    def initialize(graph, edge_weights_map, visitor)
      @graph            = graph
      @edge_weights_map = EdgePropertiesMap.new(edge_weights_map, @graph.directed?)
      @visitor          = visitor
    end

    # Finds the shortest path form the _source_ to every other vertex of the graph.
    #
    # Returns the shortest paths map that contains the shortest path (if it exists) from the source to any vertex of the
    # graph.
    #
    def shortest_paths(source)
      init(source)
      relax_edges
      PathBuilder.new(source, @visitor.parents_map).paths(@graph.vertices)
    end

    private

    def init(source)
      @visitor.set_source(source)
    end

    def relax_edges
      (@graph.size - 1).times do
        @graph.each_edge do |u, v|
          relax_edge(u, v)
          relax_edge(v, u) unless @graph.directed?
        end
      end

      @graph.each_edge do |u, v|
        if @visitor.distance_map[u] + @edge_weights_map.edge_property(u, v) < @visitor.distance_map[v]
          @visitor.handle_edge_not_minimized(u, v)
        else
          @visitor.handle_edge_minimized(u, v)
        end
      end
    end

    def relax_edge(u, v)
      @visitor.handle_examine_edge(u, v)

      new_v_distance = @visitor.distance_map[u] + @edge_weights_map.edge_property(u, v)

      if new_v_distance < @visitor.distance_map[v]
        @visitor.distance_map[v] = new_v_distance
        @visitor.parents_map[v]  = u

        @visitor.handle_edge_relaxed(u, v)
      else
        @visitor.handle_edge_not_relaxed(u, v)
      end
    end

  end # class BellmanFordAlgorithm

  module Graph

    # Finds the shortest paths from the _source_ to each vertex of the graph.
    #
    # Returns a Hash that maps each vertex of the graph to an Array of vertices that represents the shortest path
    # from the _source_ to the vertex. If the path doesn't exist, the corresponding hash value is nil. For the _source_
    # vertex returned hash contains a trivial one-vertex path - [source].
    #
    # Unlike Dijkstra algorithm, Bellman-Ford shortest paths algorithm works with negative edge weights.
    #
    # Raises ArgumentError if an edge weight is undefined.
    #
    # Raises ArgumentError or the graph has negative-weight cycles. This behavior can be overridden my a custom handler
    # for visitor's _edge_not_minimized_ event.
    #
    def bellman_ford_shortest_paths(edge_weights_map, source, visitor = BellmanFordVisitor.new(self))
      BellmanFordAlgorithm.new(self, edge_weights_map, visitor).shortest_paths(source)
    end

  end # module Graph

end # module RGL
