# transitiv_closure.rb
#
# == transitive_closure
# 
# The transitive closure of a graph G = (V,E) is a graph G* = (V,E*),
# such that E* contains an edge (u,v) if and only if G contains a path
# (of at least one edge) from u to v.  The transitive_closure() function
# transforms the input graph g into the transitive closure graph tc. 

require 'rgl/adjacency'

module RGL

  module Graph

    # Floyd-Warshal algorithm which should be O(n^3), where n is the number of 
    # nodes.  We can probably work a bit on the constant factors!
    #
    # In BGL, there is an algorithm with time complexity (worst-case) O(|V||E|)
    # (see BOOST_DOC/transitive_closure.html), based on the detection of strong
    # components.

    def transitive_closure_floyd_warshal
      raise NotDirectedError,
        "transitive_closure makes sense only for directed graphs." unless directed?
      tc = to_adjacency                     # direct links

      # indirect links

      each_vertex do |vi| 
        each_vertex do |vj| 
          each_vertex do |vk| 
            unless tc.has_edge?(vi, vj)
              tc.add_edge(vi, vj) if has_edge?(vi, vk) and
                                     has_edge?(vk, vj)
            end
          end
        end
      end
      tc
    end

    alias_method :transitive_closure, :transitive_closure_floyd_warshal

  end                           # module Graph
end                             # module RGL
