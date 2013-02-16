require 'rgl/base'
require 'rgl/graph_visitor'

require 'delegate'
require 'algorithms'

module RGL

  # Dijkstra shortest path algorithm has the following event points:
  #
  #  * examine_vertex
  #  * examine_edge
  #  * edge_relaxed
  #  * edge_not_relaxed
  #  * finish_vertex
  #
  class DijkstraVisitor

    INFINITY = 1.0 / 0.0 # positive infinity

    include GraphVisitor

    attr_accessor :distance_map, :parent_map

    def_event_handlers :edge_relaxed, :edge_not_relaxed

    # Returns visitor into initial state.
    #
    def reset
      super

      @distance_map = Hash.new(INFINITY)
      @parent_map   = {}
    end

    # Returns true if the _vertex_ can be reached from the source.
    #
    def reachable?(vertex)
      distance_map[vertex] < INFINITY
    end

  end

  class DijkstraAlgorithm

    # Initializes Dijkstra algorithm for a _graph_ with provided edges weights map.
    #
    def initialize(graph, edge_weights_map, visitor)
      check_weights(edge_weights_map)

      @graph            = graph
      @edge_weights_map = edge_weights_map
      @visitor          = visitor
      @queue            = Queue.new
    end

    # Finds the shortest path from the _source_ to the _target_ in the graph.
    #
    # Returns the shortest path, if it exists, as an Array of vertices. Otherwise, returns nil.
    #
    def shortest_path(source, target)
      init(source)
      relax_edges(target, true)
      restore_path(source, target)
    end

    # Finds the shortest path form the _source_ to every other vertex of the graph.
    #
    # Returns parents map that can be used to restore the shortest path, if it exists, from the _source_ to any vertex.
    #
    def shortest_paths(source)
      init(source)
      relax_edges
      restore_paths(source)
    end

    private

    def reset
      @visitor.reset
      @queue.clear
    end

    def init(source)
      reset

      @visitor.color_map[source]    = :GRAY
      @visitor.distance_map[source] = 0

      @queue.push(source, @visitor.distance_map[source])
    end

    def relax_edges(target = nil, break_on_target = false)
      until @queue.empty?
        u = @queue.pop

        break if break_on_target && u == target

        @visitor.handle_examine_vertex(u)

        @graph.each_adjacent(u) do |v|
          next if @visitor.finished_vertex?(v)

          if relax_edge(u, v)
            @visitor.handle_edge_relaxed(u, v)
          else
            @visitor.handle_edge_not_relaxed(u, v)
          end
        end

        @visitor.color_map[u] = :BLACK
        @visitor.handle_finish_vertex(u)
      end
    end

    def relax_edge(u, v)
      @visitor.handle_examine_edge(u, v)

      new_v_distance = @visitor.distance_map[u] + edge_weight(u, v)

      if new_v_distance < @visitor.distance_map[v]
        old_v_distance = @visitor.distance_map[v]

        @visitor.distance_map[v] = new_v_distance
        @visitor.parent_map[v]   = u

        if @visitor.color_map[v] == :WHITE
          @visitor.color_map[v] = :GRAY
          @queue.push(v, new_v_distance)
        elsif @visitor.color_map[v] == :GRAY
          @queue.decrease_key(v, old_v_distance, new_v_distance)
        end

        true
      else
        false
      end
    end

    def edge_weight(u, v)
      weight = if @graph.directed?
        @edge_weights_map[[u, v]]
      else
        @edge_weights_map[[u, v]] || @edge_weights_map[[v, u]]
      end

      validate_weight(weight, u, v)
    end

    def restore_path(source, target)
      PathBuilder.new(source, @visitor.parent_map).path(target)
    end

    def restore_paths(source)
      path_builder = PathBuilder.new(source, @visitor.parent_map)

      @graph.each_vertex do |vertex|
        path_builder.path(vertex)
      end

      path_builder.paths
    end

    def check_weights(edge_weights_map)
       edge_weights_map.each { |(u, v), weight| validate_weight(weight, u, v) } if edge_weights_map.respond_to?(:each)
    end

    def validate_weight(weight, u, v)
      report_missing_weight(weight, u, v)
      report_negative_weight(weight, u, v)

      weight
    end

    def report_missing_weight(weight, u, v)
      raise ArgumentError.new("weight of edge (#{u}, #{v}) is not defined") unless weight
    end

    def report_negative_weight(weight, u, v)
      raise ArgumentError.new("weight of edge (#{u}, #{v}) is negative") if weight < 0
    end

    class PathBuilder # :nodoc:

      attr_reader :paths

      def initialize(source, parent_map)
        @source     = source
        @parent_map = parent_map
        @paths      = {}
      end

      def path(target)
        if @paths.has_key?(target)
          @paths[target]
        else
          @paths[target] = restore_path(target)
        end
      end

      private

      def restore_path(target)
        return [@source] if target == @source

        parent = @parent_map[target]
        path(parent) + [target] if parent
      end

    end

    class Queue < SimpleDelegator # :nodoc:

      def initialize
        @heap = Containers::Heap.new { |a, b| a.distance < b.distance }
        super(@heap)
      end

      def push(vertex, distance)
        @heap.push(vertex_key(vertex, distance), vertex)
      end

      def decrease_key(vertex, old_distance, new_distance)
        @heap.change_key(vertex_key(vertex, old_distance), vertex_key(vertex, new_distance))
      end

      def vertex_key(vertex, distance)
        VertexKey.new(vertex, distance)
      end

      VertexKey = Struct.new(:vertex, :distance)

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
