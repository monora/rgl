# base.rb
#
# Module RGL defines the namespace for all modules and classes of the graph
# library. The main module is RGL::Graph which defines the abstract behavior of
# all graphs in the library.

RGL_VERSION = "0.5.6"

module RGL
  class NotDirectedError < RuntimeError; end

  class NotUndirectedError < RuntimeError; end

  class NoVertexError < IndexError; end

  class NoEdgeError < IndexError; end

  INFINITY = 1.0 / 0.0 # positive infinity

  # Module Edge includes classes for representing edges of directed and
  # undirected graphs. There is no need for a Vertex class, because every ruby
  # object can be a vertex of a graph.
  #
  module Edge
    # Simply a directed pair (source -> target). Most library functions try do
    # omit to instantiate edges. They instead use two vertex parameters for
    # representing edges (see each_edge). If a client wants to store edges
    # explicitly DirectedEdge or UnDirectedEdge instances are returned
    # (i.e. Graph#edges).
    #
    class DirectedEdge

      attr_accessor :source, :target
      # Can be used to create an edge from a two element array.
      #
      def self.[](*a)
        new(a[0], a[1])
      end

      # Create a new DirectedEdge with source _a_ and target _b_.
      #
      def initialize(a, b)
        @source, @target = a, b
      end

      # Two directed edges (u,v) and (x,y) are equal iff u == x and v == y. eql?
      # is needed when edges are inserted into a Set. eql? is aliased to ==.
      #
      def eql?(edge)
        (source == edge.source) && (target == edge.target)
      end

      alias == eql?

      def hash
        source.hash ^ target.hash
      end

      # Returns (v,u) if self == (u,v).
      #
      def reverse
        self.class.new(target, source)
      end

      # Edges can be indexed. edge[0] == edge.source, edge[n] == edge.target for
      # all n>0. Edges can thus be used as a two element array.
      #
      def [](index)
        index.zero? ? source : target
      end

      # DirectedEdge[1,2].to_s == "(1-2)"
      #
      def to_s
        "(#{source}-#{target})"
      end

      # Since Ruby 2.0 #inspect no longer calls #to_s. So we alias it to to_s (fixes #22)
      alias inspect to_s

      # Returns the array [source,target].
      #
      def to_a
        [source, target]
      end

      # Sort support is dispatched to the <=> method of Array
      #
      def <=> e
        self.to_a <=> e.to_a
      end

    end # DirectedEdge

    # An undirected edge is simply an undirected pair (source, target) used in
    # undirected graphs. UnDirectedEdge[u,v] == UnDirectedEdge[v,u]
    #
    class UnDirectedEdge < DirectedEdge
      def eql?(edge)
        super || ((target == edge.source) && (source == edge.target))
      end

      # UnDirectedEdge[1,2].to_s == "(1=2)"
      #
      def to_s
        "(#{source}=#{target})"
      end

    end

  end # Edge

  # In BGL terminology the module Graph defines the graph concept (see
  # http://www.boost.org/libs/graph/doc/graph_concepts.html). We however do not
  # distinguish between the IncidenceGraph, EdgeListGraph and VertexListGraph
  # concepts, which would complicate the interface too much. These concepts are
  # defined in BGL to differentiate between efficient access to edges and
  # vertices.
  #
  # The RGL Graph concept contains only a few requirements that are common to
  # all the graph concepts. These include, especially, the iterators defining
  # the sets of vertices and edges (see each_vertex and each_adjacent). Most
  # other functions are derived from these fundamental iterators, i.e.
  # num_vertices or num_edges.
  #
  # Each graph is an enumerable of vertices.
  #
  module Graph

    include Enumerable
    include Edge
    # The each_vertex iterator defines the set of vertices. This method must be
    # defined by concrete graph classes. It defines the BGL VertexListGraph
    # concept.
    #
    def each_vertex() # :yields: v
      raise NotImplementedError
    end

    # The each_adjacent iterator defines the out edges of vertex _v_. This
    # method must be defined by concrete graph classes. Its defines the BGL
    # IncidenceGraph concept.
    #
    def each_adjacent(v) # :yields: v
      raise NotImplementedError
    end

    # The each_edge iterator should provide efficient access to all edges of the
    # graph. Its defines the EdgeListGraph concept.
    #
    # This method must _not_ be defined by concrete graph classes, because it
    # can be implemented using each_vertex and each_adjacent. However for
    # undirected graph the function is inefficient because we must not yield
    # (v,u) if we already visited edge (u,v).
    #
    def each_edge(&block)
      if directed?
        each_vertex do |u|
          each_adjacent(u) { |v| yield u, v }
        end
      else
        each_edge_aux(&block) # concrete graphs should to this better
      end
    end

    # Vertices get enumerated. A graph is thus an enumerable of vertices.
    #
    def each(&block)
      each_vertex(&block)
    end

    # Is the graph directed? The default returns false.
    #
    def directed?
      false
    end

    # Returns true if _v_ is a vertex of the graph. Same as #include? inherited
    # from Enumerable. Complexity is O(num_vertices) by default. Concrete graph
    # may be better here (see AdjacencyGraph).
    #
    def has_vertex?(v)
      include?(v) # inherited from enumerable
    end

    # Returns true if the graph has no vertices, i.e. num_vertices == 0.
    #
    def empty?
      num_vertices.zero?
    end

    # Return the array of vertices. Synonym for #to_a inherited by Enumerable.
    #
    def vertices
      to_a
    end

    # Returns the class for edges: DirectedEdge or UnDirectedEdge.
    #
    def edge_class
      directed? ? DirectedEdge : UnDirectedEdge
    end

    # Return the array of edges (DirectedEdge or UnDirectedEdge) of the graph
    # using each_edge, depending whether the graph is directed or not.
    def edges
      result = []
      c = edge_class
      each_edge { |u, v| result << c.new(u, v) }
      result
    end

    # Returns an array of vertices adjacent to vertex _v_.
    #
    def adjacent_vertices(v)
      r = []
      each_adjacent(v) { |u| r << u }
      r
    end

    # Returns the number of out-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    #
    def out_degree(v)
      r = 0
      each_adjacent(v) { |u| r += 1 }
      r
    end

    # Returns the number of vertices.
    #
    def size # Why not in Enumerable?
      inject(0) { |n, v| n + 1 }
    end

    alias num_vertices size

    # Returns the number of edges.
    #
    def num_edges
      r = 0
      each_edge { |u, v| r +=1 }
      r
    end

    # Utility method to show a string representation of the edges of the graph.
    #
    def to_s
      edges.collect {|e| e.to_s}.sort.join
    end

    # Two graphs are equal iff they have equal directed? property as well as vertices and edges sets.
    #
    def eql?(other)
      equal?(other) || eql_graph?(other)
    end

    alias == eql?

    private

    def eql_graph?(other)
      other.is_a?(Graph) && directed? == other.directed? && eql_vertices_set?(other) && eql_edges_set?(other)
    end

    def eql_vertices_set?(other)
      other_num_vertices = 0

      other.each_vertex do |v|
        if has_vertex?(v)
          other_num_vertices += 1
        else
          return false
        end
      end

      other_num_vertices == num_vertices
    end

    def eql_edges_set?(other)
      other_num_edges = 0

      other.each_edge do |u, v|
        if has_edge?(u, v)
          other_num_edges += 1
        else
          return false
        end
      end

      other_num_edges == num_edges
    end

    def each_edge_aux
      # needed in each_edge
      visited = Hash.new

      each_vertex do |u|
        each_adjacent(u) do |v|
          edge = UnDirectedEdge.new(u, v)

          unless visited.has_key?(edge)
            visited[edge] = true
            yield u, v
          end
        end
      end
    end

  end # module Graph

end # module RGL
