require 'enumerator'

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

    # Returns an RGL::DirectedAdjacencyGraph which is the transitive reduction
    # of this graph.  Meaning, that each edge u -> v is omitted if path
    # u -> ... -> v exists.  This method supports working with cyclic graphs;
    # however, cycles are arbitrarily simplified which may lead to variant,
    # although equally valid, results on equivalent graphs.
    #
    # This method should run in O(|V||E|) time, where |V| and |E| are the number
    # of vertices and edges respectively.
    #
    # Raises RGL::NotDirectedError if run on an undirected graph.
    def transitive_reduction
      raise NotDirectedError,
        "transitive_reduction only supported for directed graphs" unless directed?

      # Compute a condensation graph in order to hide cycles.
      cg = condensation_graph

      # Use a depth first search to compute the transitive reduction over the
      # condensed graph.  This is similar to the computation of the transitive
      # closure over the graph in that for any node of the graph all nodes
      # reachable from the node are tracked.  Using a depth first search ensures
      # that all nodes reachable from a target node are known when considering
      # whether or not to add an edge pointing to that target.
      tr_cg = DirectedAdjacencyGraph.new
      paths_from = {}
      cg.depth_first_search do |v|
        paths_from[v] = Set.new
        cg.each_adjacent(v) do |w|
          # Only add the edge v -> w if there is no other edge v -> x such that
          # w is reachable from x.  Make sure to completely skip the case where
          # x == w.
          unless Enumerator.new(cg, :each_adjacent, v).any? do |x|
            x != w && paths_from[x].include?(w)
          end then
            tr_cg.add_edge(v, w)

            # For each vertex v, track all nodes reachable from v by adding node
            # w to the list as well as all the nodes readable from w.
            paths_from[v] << w
            paths_from[v].merge(paths_from[w])
          end
        end
        # Ensure that a vertex with no in or out edges is added to the graph.
        tr_cg.add_vertex(v)
      end

      # Expand the condensed transitive reduction.
      #
      # For each trivial strongly connected component in the condensed graph,
      # add the single node it contains to the new graph and add edges for each
      # edge the node begins in the original graph.
      # For each NON-trivial strongly connected component in the condensed
      # graph, add each node it contains to the new graph and add arbitrary
      # edges between the nodes to form a simple cycle.  Then for each strongly
      # connected component adjacent to the current one, find and add the first
      # edge which exists in the original graph, starts in the first strongly
      # connected component, and ends in the second strongly connected
      # component.
      g = DirectedAdjacencyGraph.new
      tr_cg.each_vertex do |scc|
        # Make a cycle of the contents of non-trivial strongly connected
        # components.
        scc_arr = scc.to_a
        if scc.size > 1 || has_edge?(scc_arr.first, scc_arr.first) then
          0.upto(scc_arr.size - 2) do |idx|
            g.add_edge(scc_arr[idx], scc_arr[idx + 1])
          end
          g.add_edge(scc_arr.last, scc_arr.first)
        end

        # Choose a single edge between the members of two different strongly
        # connected component to add to the graph.
        edges = Enumerator.new(self, :each_edge)
        tr_cg.each_adjacent(scc) do |scc2|
          g.add_edge(
            *edges.find do |v, w|
              scc.member?(v) && scc2.member?(w)
            end
          )
        end

        # Ensure that a vertex with no in or out edges is added to the graph.
        scc.each do |v|
          g.add_vertex(v)
        end
      end

      # Finally, the transitive reduction...
      g
    end
  end                           # module Graph
end                             # module RGL
