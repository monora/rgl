# bidirectional.rb
#
require 'delegate'
require 'rgl/adjacency'

module RGL

  # BGL defines the concept BidirectionalGraph as follows:
  #
  # The BidirectionalGraph concept refines DirectedAdjacencyGraph and adds the
  # requirement for efficient access to the in-edges of each vertex. This
  # concept is separated from DirectedAdjacencyGraph because, for directed graphs,
  # efficient access to in-edges typically requires more storage space,
  # and many algorithms do not require access to in-edges. For undirected
  # graphs, this is not an issue; because the in_edges() and out_edges()
  # functions are the same, they both return the edges incident to the vertex.
  #
  class BidirectionalGraph < DirectedAdjacencyGraph

    OUT = 0
    IN  = 1

    include Graph

    protected

    # @param v [Object] vertex
    # @param d [Integer] 0 = out, 1 = in
    # @return [Array] of vertices adjacent to vertex +v+ in the +d+ direction
    def adjacent_vertices_in_dir(v, d)
      (@vertices_dict[v] or raise NoVertexError, "No vertex #{v}.")[d].to_a
    end

    public

    # @param v [Object] vertex
    # @return [Array] of vertices adjacent to vertex +v+ in the _out_ direction
    #
    # @see Graph#adjacent_vertices
     def out_neighbors(v)
      adjacent_vertices_in_dir(v, OUT)
    end

    alias :adjacent_vertices :out_neighbors

    # @param v [Object] vertex
    # @return [Array] of vertices adjacent to vertex +v+ in the _in_ direction
    #
    # @see Graph#adjacent_vertices
    def in_neighbors(v)
      adjacent_vertices_in_dir(v, IN)
    end

    public

    # @param v [Object] vertex
    #
    # @see Graph#each_adjacent
    def each_out_neighbor(v, &b)
      out_neighbors(v).each(&b)
    end

    alias :each_adjacent :each_out_neighbor

    # @param v [Object] vertex
    #
    # @see Graph#each_adjacent
    def each_in_neighbor(v, &b)
      in_neighbors(v).each(&b)
    end

    # @see Graph#has_edge?
    def has_out_edge?(u, v)
      has_vertex?(u) && @vertices_dict[u][OUT].include?(v)
    end

    alias :has_edge? :has_out_edge?

    def has_in_edge?(u, v)
      has_vertex?(u) && @vertices_dict[u][IN].include?(v)
    end

    # @see MutableGraph#add_vertex
    def add_vertex(v)
      @vertices_dict[v] ||= [@edgelist_class.new, @edgelist_class.new] # out, in
    end

    # @see MutableGraph#remove_vertex.
    def remove_vertex(v)
      @vertices_dict.delete(v)

      # remove v from all adjacency lists
      @vertices_dict.each_value do |el_array|
        el_array.each { |adjList| adjList.delete(v) }
      end
    end

     # @see MutableGraph::remove_edge.
    def remove_edge(u, v)
      @vertices_dict[u][OUT].delete(v) unless @vertices_dict[u].nil?
      @vertices_dict[v][IN ].delete(u) unless @vertices_dict[v].nil?
    end

     # Converts the adjacency list of each vertex to be of type +klass+. The
    # class is expected to have a new constructor which accepts an enumerable as
    # parameter.
    # @param [Class] klass
    def edgelist_class=(klass)
      @vertices_dict.keys.each do |v|
        [OUT, IN].each do |d|
          @vertices_dict[v][d] = klass.new @vertices_dict[v].to_a
        end
      end
    end

    # @see Graph#out_degree
    def out_degree(v)
      adjacent_vertices_in_dir(v, OUT).size
    end

    # Returns the number of in-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex +v+.
    # @return [int]
    # @param (see #each_adjacent)
    def in_degree(v)
      adjacent_vertices_in_dir(v, IN).size
    end

    # Returns the number of in-edges plus out-edges (for directed graphs) or the
    # number of incident edges (for undirected graphs) of vertex _v_.
    # @return [int]
    def degree(v)
      in_degree(v) + out_degree(v)
    end

    protected

    def basic_add_edge(u, v)
      @vertices_dict[u][OUT].add(v)
      @vertices_dict[v][IN].add(u)
    end

  end

end
