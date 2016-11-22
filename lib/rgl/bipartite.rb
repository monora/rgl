require 'rgl/base'
require 'rgl/traversal'

module RGL

  module Graph

    # Separates graph's vertices into two disjoint sets so that every edge of the graph connects vertices from different
    # sets. If it's possible, the graph is bipartite.
    #
    # Returns an array of two disjoint vertices sets (represented as arrays) if the graph is bipartite. Otherwise,
    # returns nil.
    #
    def bipartite_sets
      raise NotUndirectedError.new('bipartite sets can only be found for an undirected graph') if directed?

      bfs = BipartiteBFSIterator.new(self)

      # if necessary, we start BFS from each vertex to make sure
      # that all connected components of the graph are processed
      each_vertex do |u|
        next if bfs.finished_vertex?(u)

        bfs.reset_start(u)
        bfs.move_forward_until { bfs.found_odd_cycle }

        return if bfs.found_odd_cycle
      end

      bfs.bipartite_sets_map.inject([[], []]) do |sets, (vertex, set)|
        sets[set] << vertex
        sets
      end
    end

    # Returns true if the graph is bipartite. Otherwise returns false.
    #
    def bipartite?
      !bipartite_sets.nil?
    end

  end # module Graph

  class BipartiteBFSIterator < BFSIterator

    attr_reader :bipartite_sets_map, :found_odd_cycle

    def reset
      super

      @bipartite_sets_map = {}
      @found_odd_cycle = false
    end

    def set_to_begin
      super

      @bipartite_sets_map[@start_vertex] = 0
    end

    def reset_start(new_start)
      @start_vertex = new_start
      set_to_begin
    end

    def handle_tree_edge(u, v)
      @bipartite_sets_map[v] = (@bipartite_sets_map[u] + 1) % 2 unless u.nil?  # put v into the other set
    end

    def handle_back_edge(u, v)
      verify_odd_cycle(u, v)
    end

    def handle_forward_edge(u, v)
      verify_odd_cycle(u, v)
    end

    private

    def verify_odd_cycle(u, v)
      u_set = @bipartite_sets_map[u]
      @found_odd_cycle = true if u_set && u_set == @bipartite_sets_map[v]
    end

  end # class BipartiteBFSIterator

end # module RGL
