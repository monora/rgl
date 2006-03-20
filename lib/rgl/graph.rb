# The Graph concept contains only few requirements that are common to all
# the graph concepts. These include especially the iterators defining the set of
# vertices and edges (see each_vertex and each_adjacent). Most other functions
# are derived from these fundamental iterators, i.e. num_vertices() or
# num_edges().
#
# Each graph is an enumerable of vertices.
module Graph
  include Enumerable
  include Edge

  # The each_vertex iterator defines the set of vertices. This method must be 
  # defined be concrete graph classes. It defines the BGL VertexListGraph
  # concept.
  def each_vertex
    raise NotImplementedError
    yield v                   # for RDoc
  end

  # The each_adjacent iterator defines the out edges of vertex _v_. This
  # method must be defined be concrete graph classes. Its defines the BGL
  # IncidenceGraph concept.
  def each_adjacent (v)
    raise NotImplementedError
    yield u                   # for RDoc
  end

  # The each_edge iterator should provide efficient access to all edges of the
  # graph. Its defines the EdgeListGraph concept.
  #
  # This method must _not_ be defined be concrete graph classes, because it
  # can be implemented using each_vertex and each_adjacent. However for
  # undirected graph the function is inefficient because we must may not yield
  # (v,u) if we already visited edge (u,v).
  def each_edge (&block)
   if directed?
      each_vertex { |u| each_adjacent(u) { |v| yield u,v } }
    else
      each_edge_aux(&block)       # concrete graphs should to this better
    end
  end
  
  # Vertices get enumerated. A graph is thus an enumerable of vertices.
  # ---
  # === Testing
  def each(&block); each_vertex(&block); end
  
  # Is the graph directed? The default returns false.
  def directed?; false; end

  # Returns true if _v_ is a vertex of the graph. Same as include? inherited
  # from enumerable. Complexity is O(num_vertices) by default. Concrete graph
  # may bee better here (see AdjacencyGraph).
  def has_vertex?(v); include?(v); end    # inherited from enumerable

  # Returns true if the graph has no vertex, i.e. num_vertices == 0.
  # ---
  # === accessing vertices and edges
  def empty?; num_vertices.zero?; end

  # Return the array of vertices. Synonym for to_a inherited by enumerable.
  def vertices; to_a; end

  # Returns the class for edges: DirectedEdge or UnDirectedEdge.
  def edge_class; directed? ? DirectedEdge : UnDirectedEdge; end

  # Return the array of edges (DirectedEdge or UnDirectedEdge) of the graph
  # using each_edge, depending whether the graph is directed or not.
  def edges
    result = []
    c = edge_class
    each_edge { |u,v| result << c.new(u,v) }
    result
  end

  # Returns an array of vertices adjacent to vertex _v_.
  def adjacent_vertices (v)
    r = []
    each_adjacent(v) {|u| r << u}
    r
  end

  # Returns the number of out-edges (for directed graphs) or the number of
  # incident edges (for undirected graphs) of vertex _v_.
  def out_degree (v)
    r = 0
    each_adjacent(v) { |u| r += 1}
    r
  end

  # Returns the number of vertices.
  def size()                  # Why not in Enumerable?
    inject(0) { |n, v| n + 1 }
    #r = 0; each_vertex {|v| r +=1}; r
  end

  # Synonym for size.
  def num_vertices; size; end

  # Returns the number of edges.
  def num_edges; r = 0; each_edge {|u,v| r +=1}; r; end

  # Utility method to show a string representation of the edges of the graph.
  def to_s
    edges.sort.to_s
  end

  # Equality is defined to be same set of edges and directed?
  def eql?(g) (g.directed? == self.directed?) && (g.edges.sort == edges.sort); end
  alias == eql?

 private
  
  def each_edge_aux
    # needed in each_edge
    visited = Hash.new
    each_vertex do |u|
      each_adjacent(u) do |v|
        edge = UnDirectedEdge.new u,v
        unless visited.has_key? edge
          visited[edge]=true
          yield u, v
        end
      end
    end
  end

end                  
