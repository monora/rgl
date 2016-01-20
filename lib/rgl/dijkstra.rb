require 'rgl/dijkstra_visitor'
require 'rgl/edge_properties_map'
require 'rgl/path_builder'

require 'lazy_priority_queue'

module RGL

  class DijkstraAlgorithm

    # Distance combinator is a lambda that accepts the distance (usually from the source) to vertex _u_ and the weight
    # of the edge connecting vertex _u_ to another vertex _v_ and returns the distance to vertex _v_ if it's reached
    # through the vertex _u_. By default, the distance to vertex _u_ and the edge's weight are summed.
    DEFAULT_DISTANCE_COMBINATOR = lambda { |distance, edge_weight| distance + edge_weight }

    # Initializes Dijkstra's algorithm for a _graph_ with provided edges weights map.
    #
    def initialize(graph, edge_weights_map, visitor, distance_combinator = nil)
      @graph               = graph
      @edge_weights_map    = build_edge_weights_map(edge_weights_map)
      @visitor             = visitor
      @distance_combinator = distance_combinator || DEFAULT_DISTANCE_COMBINATOR
    end

    # Finds the shortest path from the _source_ to the _target_ in the graph.
    #
    # Returns the shortest path, if it exists, as an Array of vertices. Otherwise, returns nil.
    #
    def shortest_path(source, target)
      init(source)
      relax_edges(target, true)
      PathBuilder.new(source, @visitor.parents_map).path(target)
    end

    # Finds the shortest path form the _source_ to every other vertex of the graph and builds shortest paths map.
    #
    # Returns the shortest paths map that contains the shortest path (if it exists) from the source to any vertex of the
    # graph.
    #
    def shortest_paths(source)
      find_shortest_paths(source)
      PathBuilder.new(source, @visitor.parents_map).paths(@graph.vertices)
    end

    # Finds the shortest path from the _source_ to every other vertex.
    #
    def find_shortest_paths(source)
      init(source)
      relax_edges
    end

    private

    def init(source)
      @visitor.set_source(source)

      @queue = MinPriorityQueue.new
      @queue.push(source, 0)
    end

    def relax_edges(target = nil, break_on_target = false)
      until @queue.empty?
        u = @queue.pop

        break if break_on_target && u == target

        @visitor.handle_examine_vertex(u)

        @graph.each_adjacent(u) do |v|
          relax_edge(u, v) unless @visitor.finished_vertex?(v)
        end

        @visitor.color_map[u] = :BLACK
        @visitor.handle_finish_vertex(u)
      end
    end

    def relax_edge(u, v)
      @visitor.handle_examine_edge(u, v)

      new_v_distance = @distance_combinator.call(@visitor.distance_map[u], @edge_weights_map.edge_property(u, v))

      if new_v_distance < @visitor.distance_map[v]
        @visitor.distance_map[v] = new_v_distance
        @visitor.parents_map[v]  = u

        if @visitor.color_map[v] == :WHITE
          @visitor.color_map[v] = :GRAY
          @queue.push(v, new_v_distance)
        elsif @visitor.color_map[v] == :GRAY
          @queue.decrease_key(v, new_v_distance)
        end

        @visitor.handle_edge_relaxed(u, v)
      else
        @visitor.handle_edge_not_relaxed(u, v)
      end
    end

    def build_edge_weights_map(edge_weights_map)
      edge_weights_map.is_a?(EdgePropertiesMap) ? edge_weights_map : NonNegativeEdgePropertiesMap.new(edge_weights_map, @graph.directed?)
    end

  end # class DijkstraAlgorithm

  module Graph

    # Finds the shortest path from the _source_ to the _target_ in the graph.
    #
    # If the path exists, returns it as an Array of vertices. Otherwise, returns nil.
    #
    # Raises ArgumentError if edge weight is negative or undefined.
    #
    def dijkstra_shortest_path(edge_weights_map, source, target, visitor = DijkstraVisitor.new(self))
      DijkstraAlgorithm.new(self, edge_weights_map, visitor).shortest_path(source, target)
    end

    # Finds the shortest paths from the _source_ to each vertex of the graph.
    #
    # Returns a Hash that maps each vertex of the graph to an Array of vertices that represents the shortest path
    # from the _source_ to the vertex. If the path doesn't exist, the corresponding hash value is nil. For the _source_
    # vertex returned hash contains a trivial one-vertex path - [source].
    #
    # Raises ArgumentError if edge weight is negative or undefined.
    #
    def dijkstra_shortest_paths(edge_weights_map, source, visitor = DijkstraVisitor.new(self))
      DijkstraAlgorithm.new(self, edge_weights_map, visitor).shortest_paths(source)
    end

  end # module Graph

end # module RGL
