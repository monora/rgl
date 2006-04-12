require 'rgl/base'

module RGL

  # BGL defines the concept BidirectionalGraph as follows:
  # 
  # The BidirectionalGraph concept refines IncidenceGraph and adds the
  # requirement for efficient access to the in-edges of each vertex.  This
  # concept is separated from IncidenceGraph because, for directed graphs,
  # efficient access to in-edges typically requires more storage space,
  # and many algorithms do not require access to in-edges.  For undirected
  # graphs, this is not an issue; because the in_edges() and out_edges()
  # functions are the same, they both return the edges incident to the vertex.
  module BidirectionalGraph
    include Graph

    # Iterator providing access to the in-edges (for directed graphs) or incident
    # edges (for undirected graphs) of vertex _v_. For both directed and
    # undirected graphs, the target of an out-edge is required to be vertex _v_
    # and the source is required to be a vertex that is adjacent to _v_.
    def each_in_neighbor (v)
      raise NotImplementedError
      yield u
    end
    
    # Returns the number of in-edges (for directed graphs) or the number of
    # incident edges (for undirected graphs) of vertex _v_.
    def in_degree (v)
      r = 0;
      each_in_neighbor(v) { |u| r += 1}
      r
    end

    # Returns the number of in-edges plus out-edges (for directed graphs) or the 
    # number of incident edges (for undirected graphs) of vertex _v_.
    def degree (v)
      in_degree(v) + out_degree(v)
    end
  end
end
