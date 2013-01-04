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

    def reset
      super

      @distance_map = Hash.new(INFINITY)
      @parent_map   = {}
    end

    def reachable?(vertex)
      distance_map[vertex] < INFINITY
    end

  end

  class DijkstraAlgorithm

    def initialize(graph, edge_weights_map, visitor)
      @graph            = graph
      @edge_weights_map = edge_weights_map
      @visitor          = visitor
      @queue            = DijkstraQueue.new
    end

    # Finds the shortest path from the _source_ to the _target_ in the graph.
    #
    def shortest_path(source, target)
      reset

      @visitor.color_map[source]    = :GRAY
      @visitor.distance_map[source] = 0

      @queue.push(source, @visitor.distance_map[source])

      until @queue.empty?
        u = @queue.pop

        break if u == target

        @visitor.handle_examine_vertex(u)

        @graph.each_adjacent(u) do |v|
          if relax_edge(u, v)
            @visitor.handle_edge_relaxed(u, v)
          else
            @visitor.handle_edge_not_relaxed(u, v)
          end
        end

        @visitor.color_map[u] = :BLACK
        @visitor.handle_finish_vertex(u)
      end

      build_path(target)
    end

    private

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

    def reset
      @visitor.reset
      @queue.clear
    end

    def edge_weight(u, v)
      if @graph.directed?
        @edge_weights_map[[u, v]]
      else
        @edge_weights_map[[u, v]] || @edge_weights_map[[v, u]]
      end
    end

    def build_path(target)
      return unless @visitor.reachable?(target)

      path = [target]
      last = @visitor.parent_map[target]

      while last
        path.unshift(last)
        last = @visitor.parent_map[last]
      end

      path
    end

    class DijkstraQueue < SimpleDelegator

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

    def dijkstra_shortest_path(edge_weights_map, source, target, visitor = DijkstraVisitor.new(self))
      DijkstraAlgorithm.new(self, edge_weights_map, visitor).shortest_path(source, target)
    end

  end # module Graph

end # module RGL
