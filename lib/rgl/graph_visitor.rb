require 'rgl/graph_wrapper'

module RGL

  # Module GraphVisitor defines the BGL
  # BFS[http://www.boost.org/libs/graph/doc/BFSVisitor.html] Visitor Concept.
  #
  # Visitors provide a mechanism for extending an algorithm (i.e., for
  # customizing what is done at each step of the algorithm). They allow users
  # to insert their own operations at various steps within a graph algorithm.
  #
  # Graph algorithms typically have multiple event points where one may want to
  # insert a call-back. Therefore, visitors have several methods that
  # correspond to the various event points. Each algorithm has a different
  # set of event points. The following are common to both DFS and BFS search.
  #
  #  * examine_vertex
  #  * examine_edge
  #  * tree_edge
  #  * back_edge
  #  * forward_edge
  #  * finish_vertex
  #
  # These methods are all called handle_* and can be set to appropriate blocks,
  # using the methods set_*_event_handler, which are defined for each event
  # mentioned above.
  #
  # As an alternative, you can also override the handle_* methods in a
  # subclass, to configure the algorithm (as an example, see TarjanSccVisitor).
  #
  # During a graph traversal, vertices are *colored* using the colors :GRAY
  # (when waiting) and :BLACK when finished. All other vertices are :WHITE.
  # The color_map is also maintained in the visitor.
  #
  module GraphVisitor

    include GraphWrapper

    attr_reader :color_map

    # Create a new GraphVisitor on _graph_.
    #
    def initialize(graph)
      super(graph)
      reset
    end

    # Mark each vertex unvisited (i.e. :WHITE)
    #
    def reset
      @color_map = Hash.new(:WHITE)
    end

    # Returns true if vertex _v_ is colored :BLACK (i.e. finished).
    #
    def finished_vertex?(v)
      @color_map[v] == :BLACK
    end

    # Shall we follow the edge (u,v); i.e. v has color :WHITE
    #
    def follow_edge?(u, v) # :nodoc:
      @color_map[v] == :WHITE
    end

    # Attach a map to the visitor which records the distance of a visited
    # vertex to the start vertex.
    #
    # This is similar to BGLs
    # distance_recorder[http://www.boost.org/libs/graph/doc/distance_recorder.html].
    #
    # After the distance_map is attached, the visitor has a new method
    # distance_to_root, which answers the distance to the start vertex.
    #
    def attach_distance_map(map = Hash.new(0))
      @distance_map = map

      # add distance map support to the current visitor instance
      extend(DistanceMapSupport)
    end

    module DistanceMapSupport

      def handle_tree_edge(u, v)
        super
        @distance_map[v] = @distance_map[u] + 1
      end

      # Answer the distance to the start vertex.

      def distance_to_root(v)
        @distance_map[v]
      end

    end # module DistanceMapSupport

    module ClassMethods

      # Defines an event handler.
      #
      def def_event_handlers(*events)
        events.each do |event|
          params = event.to_s.include?('edge') ? 'u, v' : 'u'

          handler = "@#{event}_event_handler"

          class_eval <<-END
            def handle_#{event}(#{params})
              #{handler}.call(#{params}) if defined? #{handler}
            end

            def set_#{event}_event_handler(&block)
              #{handler} = block
            end
          END
        end
      end

      alias def_event_handler def_event_handlers

    end # module ClassMethods

    extend ClassMethods # add class methods to GraphVisitor class itself

    def self.included(base)
      base.extend ClassMethods # when GraphVisitor is included into a class/module, add class methods as well
    end

    def_event_handlers :examine_vertex,
                       :examine_edge,
                       :tree_edge,
                       :back_edge,
                       :forward_edge,
                       :finish_vertex

  end # module GraphVisitor

end # module RGL