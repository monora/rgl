# edge.rb
#

# Module Edge includes classes for representing egdes of directed and
# undirected graphs. There is no need for a Vertex class, because every ruby
# object can be a vertex of a graph.
module Edge
  # Simply a directed pair (source -> target). Must library functions try do
  # omit to instantiate edges. They instead use two vertex parameters for
  # representing edges (see each_edge). If a client wants to store edges
  # explicitly DirectedEdge or UnDirectedEdge instances are returned
  # (i.e. Graph#edges). 

  class DirectedEdge
    attr_accessor :source, :target

    # Can be used to create an edge from a two element array.
    def self.[](*a)
      new(a[0],a[1])
    end

    # Create a new DirectedEdge with source _a_ and target _b_.
    def initialize (a,b)
      @source, @target = a,b
    end
    
    # Two directed edges (u,v) and (x,y) are equal iff u == x and v == y. eql?
    # is needed when edges are inserted into a Set. eql? is aliased to ==.
    def eql?(edge)
      source == edge.source and target == edge.target
    end
    alias == eql?

    # Returns (v,u) if self == (u,v).
    def reverse
      self.class.new(target, source)
    end

    # Edges can be indexed. edge[0] == edge.source, edge[n] == edge.target for
    # all n>0. Edges can thus be used as a two element array.
    def [](index); index.zero? ? source : target; end

    # DirectedEdge[1,2].to_s == "(1-2)"
    def to_s
      "(#{source}-#{target})"
    end
    # Returns the array [source,target].
    def to_a; [source,target]; end

    # Sort support is dispatched to the <=> method of Array
    def <=> e
      self.to_a <=> e.to_a
    end
  end                         # DirectedEdge

  # An undirected edge is simply an undirected pair (source, target) used in
  # undirected graphs. UnDirectedEdge[u,v] == UnDirectedEdge[v,u]
  class UnDirectedEdge < DirectedEdge
    def eql?(edge)
      super or (target == edge.source and source == edge.target)
    end
    
    def hash
      source.hash ^ target.hash
    end
    
    # UnDirectedEdge[1,2].to_s == "(1=2)"
    def to_s; "(#{source}=#{target})"; end
  end

end
