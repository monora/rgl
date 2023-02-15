# bidirectional_adjacency.rb
#
require 'rgl/adjacency'
require 'rgl/bidirectional'

module RGL

  # BGL defines the concept BidirectionalGraph as follows:
  #
  # The BidirectionalGraph concept refines IncidenceGraph and adds the
  # requirement for efficient access to the in-edges of each vertex. This
  # concept is separated from IncidenceGraph because, for directed graphs,
  # efficient access to in-edges typically requires more storage space,
  # and many algorithms do not require access to in-edges. For undirected
  # graphs, this is not an issue; because the in_edges() and out_edges()
  # functions are the same, they both return the edges incident to the vertex.

  # This implementation simply creates an internal DirectedAdjacencyGraph to store
  # the in-edges and overrides methods to ensure that the out and in graphs
  # remain synchronized.
  #
  class BidirectionalAdjacencyGraph < DirectedAdjacencyGraph

    include BidirectionalGraph

    # @see DirectedAdjacencyGraph#initialize
    def initialize(edgelist_class = Set, *other_graphs)
      super(edgelist_class, *other_graphs)
      @reverse = self.reverse
    end

    # We don't need to override add_vertex() because the reverse graph doesn't need to
    # contain any unconnected vertices. Vertices will be added by add_edge() as
    # required.

    # @see MutableGraph#add_edge.
    def add_edge(u, v)
      super(u, v)
      @reverse.add_edge(v, u)
    end

    # @see MutableGraph#remove_vertex.
    def remove_vertex(v)
      super(v)
      @reverse.remove_vertex(v)
    end

    # @see MutableGraph::remove_edge.
    def remove_edge(u, v)
      super(u, v)
      @reverse.remove_edge(v, u)
    end

    # @see Graph#has_edge?
    def has_in_edge?(u, v)
      @reverse.has_edge?(u, v)
    end

    alias :has_out_edge? :has_edge?

    # Iterator providing access to the in-edges (for directed graphs) or incident
    # edges (for undirected graphs) of vertex _v_. For both directed and
    # undirected graphs, the target of an out-edge is required to be vertex _v_
    # and the source is required to be a vertex that is adjacent to _v_.
    #
    def each_in_neighbor(v)
      @reverse.each_adjacent(v)
    end

    alias :each_out_neighbor :each_adjacent

    def in_neighbors(v)
      @reverse.adjacent_vertices(v)
    end

    alias :out_neighbors :adjacent_vertices

    # Returns the number of in-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    # @return [int]
    def in_degree(v)
      @reverse.out_degree(v)
    end

 end

end
