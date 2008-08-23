require 'rgl/base'
require 'rgl/implicit'

module RGL
  module Graph
    # Returns an RGL::ImplicitGraph where the strongly connected components of
    # this graph are condensed into single nodes represented by Set instances
    # containing the members of each strongly connected component.  Edges
    # between the different strongly connected components are preserved while
    # edges within strongly connected components are omitted.
    #
    # Raises RGL::NotDirectedError if run on an undirected graph.
    def condensation_graph
      raise NotDirectedError,
        "condensation_graph only supported for directed graphs" unless directed?

      # Get the component map for the strongly connected components.
      comp_map = strongly_connected_components.comp_map
      # Invert the map such that for any number, n, in the component map a Set
      # instance is created containing all of the nodes which map to n.  The Set
      # instances will be used to map to the number, n, with which the elements
      # of the set are associated.
      inv_comp_map = {}
      comp_map.each { |v, n| (inv_comp_map[n] ||= Set.new) << v }

      # Create an ImplicitGraph where the nodes are the strongly connected
      # components of this graph and the edges are the edges of this graph which
      # cross between the strongly connected components.
      ImplicitGraph.new do |g|
        g.vertex_iterator do |b|
          inv_comp_map.each_value(&b)
        end
        g.adjacent_iterator do |scc, b|
          scc.each do |v|
            each_adjacent(v) do |w|
              # Do not make the cluster reference itself in the graph.
              if comp_map[v] != comp_map[w] then
                b.call(inv_comp_map[comp_map[w]])
              end
            end
          end
        end
        g.directed = true
      end
    end
  end
end
