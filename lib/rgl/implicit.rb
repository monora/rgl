# implicit.rb 
#
# This file contains the definition of the class RGL::ImplicitGraph, which
# defines vertex and edge iterators using blocks (which again call blocks).
# 
# An ImplicitGraph provides a handy way to define graphs on the fly, using two
# blocks for the two iterators defining a graph.  A directed cyclic graph,
# with five vertices can be created as follows:
#
#   g = RGL::ImplicitGraph.new { |g|
#     g.vertex_iterator { |b| 0.upto(4,&b) }
#     g.adjacent_iterator { |x, b| b.call((x+1)%5) }
#     g.directed = true
#   }
#
#   g.to_s => "(0-1)(1-2)(2-3)(3-4)(4-0)"
#
# Other examples are given by the methods vertices_filtered_by and
# edges_filtered_by, which can be applied to any graph.

require 'rgl/base'

module RGL

  class ImplicitGraph

    include Graph

    attr_writer :directed

    EMPTY_VERTEX_ITERATOR   = proc { |b|    }
    EMPTY_NEIGHBOR_ITERATOR = proc { |x, b| }
        
    # Create a new ImplicitGraph, which is empty by default.  The caller should
    # configure the graph using vertex and neighbor iterators.  If the graph is
    # directed, the client should set _directed_ to true.  The default value
    # for _directed_ is false. 

    def initialize
      @directed = false
      @vertex_iterator   = EMPTY_VERTEX_ITERATOR
      @adjacent_iterator = EMPTY_NEIGHBOR_ITERATOR
      yield self if block_given?  # Let client overwrite defaults.
    end

    # Returns the value of @directed.

    def directed?
      @directed
    end
        
    def each_vertex (&block)			# :nodoc:
      @vertex_iterator.call(block)
    end

    def each_adjacent (v, &block)		# :nodoc:
      @adjacent_iterator.call(v, block)
    end

    def each_edge (&block)			# :nodoc:
      if defined? @edge_iterator
        @edge_iterator.call(block)
      else
        super					# use default implementation
      end
    end

    # Sets the vertex_iterator to _block_,
    # which must be a block of one parameter
    # which again is the block called by each_vertex.

    def vertex_iterator (&block)
      @vertex_iterator = block
    end

    # Sets the adjacent_iterator to _block_,
    # which must be a block of two parameters: 
    #
    #   The first parameter is the vertex the neighbors of which are to be
    #   traversed.
    #
    #   The second is the block which will be called for each neighbor
    #   of this vertex.

    def adjacent_iterator (&block)
      @adjacent_iterator = block
    end

    # Sets the edge_iterator to _block_, which must be a block of two
    # parameters: The first parameter is the source of the edges; the
    # second is the target of the edge.

    def edge_iterator (&block)
      @edge_iterator = block
    end

  end		# class ImplicitGraph


  module Graph

    # ---
    # === Graph adaptors
    #
    # Return a new ImplicitGraph which has as vertices all vertices of the
    # receiver which satisfy the predicate _filter_.
    #
    # The methods provides similar functionaty as the BGL graph adapter
    # filtered_graph (see BOOST_DOC/filtered_graph.html). 
    #
    # ==== Example
    #
    #   def complete (n)
    #     set = n.integer? ? (1..n) : n
    #     RGL::ImplicitGraph.new { |g|
    #           g.vertex_iterator { |b| set.each(&b) }
    #           g.adjacent_iterator { |x, b|
    #             set.each { |y| b.call(y) unless x == y }
    #           }
    #     }
    #   end
    #
    #   complete(4).to_s =>     "(1=2)(1=3)(1=4)(2=3)(2=4)(3=4)"
    #   complete(4).vertices_filtered_by {|v| v != 4}.to_s => "(1=2)(1=3)(2=3)"

    def vertices_filtered_by (&filter)
      implicit_graph { |g|
        g.vertex_iterator { |b|
          self.each_vertex { |v| b.call(v) if filter.call(v) }
        }
        g.adjacent_iterator { |v, b|
          self.each_adjacent(v) { |u| b.call(u) if filter.call(u) }
        }
      }
    end

    # Return a new ImplicitGraph which has as edges all edges of the receiver
    # which satisfy the predicate _filter_ (a block with two parameters).
    #
    # ==== Example
    #
    #       g = complete(7).edges_filtered_by {|u,v| u+v == 7}
    #       g.to_s     => "(1=6)(2=5)(3=4)"
    #       g.vertices => [1, 2, 3, 4, 5, 6, 7]

    def edges_filtered_by (&filter)
      implicit_graph { |g|
        g.adjacent_iterator { |v, b|
          self.each_adjacent(v) { |u|
            b.call(u) if filter.call(v, u)
          }
        }
        g.edge_iterator { |b|
          self.each_edge { |u,v| b.call(u, v) if filter.call(u, v) }
        }
      }
    end

    # Return a new ImplicitGraph which is isomorphic (i.e. has same edges and
    # vertices) to the receiver.  It is a shortcut, also used by
    # edges_filtered_by and vertices_filtered_by.

    def implicit_graph
      result = ImplicitGraph.new { |g|
        g.vertex_iterator { |b| self.each_vertex(&b) }
        g.adjacent_iterator { |v, b| self.each_adjacent(v, &b) }
        g.directed = self.directed?
      }
      yield result if block_given? # let client overwrite defaults
      result
    end

  end		# module Graph
end		# module RGL
