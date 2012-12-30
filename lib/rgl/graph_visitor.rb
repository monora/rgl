require 'rgl/graph_wrapper'

module RGL

  # Module GraphVisitor defines the BGL
  # BFS[http://www.boost.org/libs/graph/doc/BFSVisitor.html] Visitor Concept).
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
  #  * finish_vertex
  #  * examine_edge
  #  * tree_edge
  #  * back_edge
  #  * forward_edge
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
      @dist_map = map

      class << self
        def handle_tree_edge(u, v)
          super
          @dist_map[v] = @dist_map[u] + 1
        end

        # Answer the distance to the start vertex.

        def distance_to_root(v)
          @dist_map[v]
        end
      end # class
    end

    # Shall we follow the edge (u,v); i.e. v has color :WHITE
    #
    def follow_edge?(u, v) # :nodoc:
      @color_map[v] == :WHITE
    end

    # == Visitor Event Points
    #
    def self.def_event_handler(m)
      params = m =~ /edge/ ? "u,v" : "u"
      self.class_eval %{
        def handle_#{m} (#{params})
          @#{m}_event_handler.call(#{params}) if defined? @#{m}_event_handler
        end

        def set_#{m}_event_handler (&b)
          @#{m}_event_handler = b
        end
      }
    end

    %w[examine_vertex finish_vertex examine_edge tree_edge back_edge
       forward_edge].each do |m|
      def_event_handler(m)
    end

  end # module GraphVisitor

end # module RGL