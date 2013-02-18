require 'rgl/base'
require 'rgl/graph_visitor'

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

    include GraphVisitor

    attr_accessor :distance_map, :parents_map

    def_event_handlers :edge_relaxed, :edge_not_relaxed

    # Returns visitor into initial state.
    #
    def reset
      super

      @distance_map = Hash.new(INFINITY)
      @parents_map  = {}
    end

    # Initializes visitor with a new source.
    #
    def set_source(source)
      reset

      color_map[source]    = :GRAY
      distance_map[source] = 0
    end

  end # DijkstraVisitor

end # RGL