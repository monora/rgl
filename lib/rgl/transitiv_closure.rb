# transitiv_closure.rb
#
# == transitive_closure
#
# The transitive closure of a graph G = (V,E) is a graph G* = (V,E*),
# such that E* contains an edge (u,v) if and only if G contains a path
# (of at least one edge) from u to v.  The transitive_closure() function
# transforms the input graph g into the transitive closure graph tc.

require 'rgl/adjacency'
require 'rgl/base'
require 'rgl/condensation'

module RGL
  module Graph
    # Returns an RGL::DirectedAdjacencyGraph which is the transitive closure of
    # this graph.  Meaning, for each path u -> ... -> v in this graph, the path
    # is copied and the edge u -> v is added.  This method supports working with
    # cyclic graphs by ensuring that edges are created between every pair of
    # vertices in the cycle, including self-referencing edges.
    #
    # This method should run in O(|V||E|) time, where |V| and |E| are the number
    # of vertices and edges respectively.
    #
    # Raises RGL::NotDirectedError if run on an undirected graph.
    def transitive_closure
      raise NotDirectedError,
        "transitive_closure only supported for directed graphs" unless directed?

      # Compute a condensation graph in order to hide cycles.
      cg = condensation_graph

      # Use a depth first search to calculate the transitive closure over the
      # condensation graph.  This ensures that as we traverse up the graph we
      # know the transitive closure of each subgraph rooted at each node
      # starting at the leaves.  Subsequent root nodes which consume these
      # subgraphs by way of the nodes' immediate successors can then immediately
      # add edges to the roots of the subgraphs and to every successor of those
      # roots.
      tc_cg = DirectedAdjacencyGraph.new
      cg.depth_first_search do |v|
        # For each vertex v, w, and x where the edges v -> w and w -> x exist in
        # the source graph, add edges v -> w and v -> x to the target graph.
        cg.each_adjacent(v) do |w|
          tc_cg.add_edge(v, w)
          tc_cg.each_adjacent(w) do |x|
            tc_cg.add_edge(v, x)
          end
        end
        # Ensure that a vertex with no in or out edges is added to the graph.
        tc_cg.add_vertex(v)
      end

      # Expand the condensed transitive closure.
      #
      # For each trivial strongly connected component in the condensed graph,
      # add the single node it contains to the new graph and add edges for each
      # edge the node begins in the original graph.
      # For each NON-trivial strongly connected component in the condensed
      # graph, add each node it contains to the new graph and add edges to
      # every node in the strongly connected component, including self
      # referential edges.  Then for each edge of the original graph from any
      # of the contained nodes, add edges from each of the contained nodes to
      # all the edge targets.
      g = DirectedAdjacencyGraph.new
      tc_cg.each_vertex do |scc|
        scc.each do |v|
          # Add edges between all members of non-trivial strongly connected
          # components (size > 1) and ensure that self referential edges are
          # added when necessary for trivial strongly connected components.
          if scc.size > 1 || has_edge?(v, v) then
            scc.each do |w|
              g.add_edge(v, w)
            end
          end
          # Ensure that a vertex with no in or out edges is added to the graph.
          g.add_vertex(v)
        end
        # Add an edge from every member of a strongly connected component to
        # every member of each strongly connected component to which the former
        # points.
        tc_cg.each_adjacent(scc) do |scc2|
          scc.each do |v|
            scc2.each do |w|
              g.add_edge(v, w)
            end
          end
        end
      end

      # Finally, the transitive closure...
      g
    end
  end                           # module Graph
end                             # module RGL
