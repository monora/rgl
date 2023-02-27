# bidirectional_adjacency.rb
#
require 'rgl/adjacency'
require 'rgl/bidirectional'

module RGL

  # This implementation of {BidirectionalGraph} creates an internal
  # {DirectedAdjacencyGraph} to store the in-edges and overrides methods
  # to ensure that the out and in graphs remain synchronized.
  #
  class BidirectionalAdjacencyGraph < DirectedAdjacencyGraph

    include BidirectionalGraph

    # @see DirectedAdjacencyGraph#initialize
    #
    # In super method the in edges are also added since {add_edge} of this class
    # also inserts edges in `@reverse`.
    def initialize(edgelist_class = Set, *other_graphs)
      @reverse = DirectedAdjacencyGraph.new(edgelist_class)
      super(edgelist_class, *other_graphs)
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

    # @see BidirectionalGraph#each_in_neighbor
    def each_in_neighbor(v, &b)
      @reverse.each_adjacent(v, &b)
    end

    alias :each_out_neighbor :each_adjacent

    def in_neighbors(v)
      @reverse.adjacent_vertices(v)
    end

    # Returns the number of in-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    # @return [int]
    def in_degree(v)
      @reverse.out_degree(v)
    end

  end

end
