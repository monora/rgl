# connected_components.rb
#
# This file contains the algorithms for the connected components of an
# undirected graph (each_connected_component) and strongly connected components
# for directed graphs (strongly_connected_components).
#
require 'rgl/traversal'

module RGL

  module Graph

    # Compute the connected components of an undirected graph, using a
    # DFS (Depth-first search)-based approach.  A _connected component_ of
    # an undirected graph is a set of vertices that are all reachable
    # from each other.
    #
    # The function is implemented as an iterator which calls the client
    # with an array of vertices for each component.
    #
    # It raises an exception if the graph is directed.

    def each_connected_component
      raise NotUndirectedError,
        "each_connected_component only works " +
        "for undirected graphs." if directed?
      comp = []
      vis  = DFSVisitor.new(self)
      vis.set_finish_vertex_event_handler { |v| comp << v }
      vis.set_start_vertex_event_handler { |v|
        yield comp unless comp.empty?
        comp = []
      }
      depth_first_search(vis) { |v| }
      yield comp unless comp.empty?
    end

    # This GraphVisitor is used by strongly_connected_components to compute
    # the strongly connected components of a directed graph.

    class TarjanSccVisitor < DFSVisitor

      attr_reader :comp_map

      # Creates a new TarjanSccVisitor for graph _g_, which should be directed.

      def initialize (g)
        super g
        @root_map           = {}
        @comp_map           = {}
        @discover_time_map  = {}
        @dfs_time           = 0
        @c_index            = 0
        @stack              = []
      end

      def handle_examine_vertex (v)
        @root_map[v] =  v
        @comp_map[v] =  -1
        @dfs_time    += 1
        @discover_time_map[v] = @dfs_time
        @stack.push(v)
      end

      def handle_finish_vertex (v)
        # Search adjacent vertex w with earliest discover time
        root_v = @root_map[v]
        graph.each_adjacent(v) do |w|
          if @comp_map[w] == -1
            root_v = min_discover_time(root_v, @root_map[w])
          end
        end
        @root_map[v] = root_v
        if root_v == v                  # v is topmost vertex of a SCC
          begin                         # pop off all vertices until v
            w = @stack.pop
            @comp_map[w] = @c_index
          end until w == v
          @c_index += 1
        end
      end

      # Return the number of components found so far.

      def num_comp
        @c_index
      end

      private

      def min_discover_time (u, v)
        @discover_time_map[u] < @discover_time_map[v] ? u : v
      end

    end		# class TarjanSccVisitor

    # This is Tarjan's algorithm for strongly connected components, from his
    # paper "Depth first search and linear graph algorithms".  It calculates
    # the components in a single application of DFS.  We implement the
    # algorithm with the help of the DFSVisitor TarjanSccVisitor.
    #
    # === Definition
    # 
    # A _strongly connected component_ of a directed graph G=(V,E) is a
    # maximal set of vertices U which is in V, such that for every pair of
    # vertices u and  v in U, we have both a path from u to v and a path
    # from v to u. That is to say, u and v are reachable from each other.
    # 
    # @Article{Tarjan:1972:DFS,
    #   author =       "R. E. Tarjan",
    #   key =          "Tarjan",
    #   title =        "Depth First Search and Linear Graph Algorithms",
    #   journal =      "SIAM Journal on Computing",
    #   volume =       "1",
    #   number =       "2",
    #   pages =        "146--160",
    #   month =        jun,
    #   year =         "1972",
    #   CODEN =        "SMJCAT",
    #   ISSN =         "0097-5397 (print), 1095-7111 (electronic)",
    #   bibdate =      "Thu Jan 23 09:56:44 1997",
    #   bibsource =    "Parallel/Multi.bib, Misc/Reverse.eng.bib",
    # }
    # 
    # The output of the algorithm is recorded in a TarjanSccVisitor _vis_.
    # vis.comp_map will contain numbers giving the component ID assigned to
    # each vertex. The number of components is vis.num_comp.

    def strongly_connected_components
      raise NotDirectedError,
        "strong_components only works for directed graphs." unless directed?
      vis = TarjanSccVisitor.new(self)
      depth_first_search(vis) { |v| }
      vis
    end

  end                           # module Graph
end                             # module RGL
