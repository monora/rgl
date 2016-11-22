require 'rgl/edge_properties_map'
require 'rgl/traversal'

module RGL

  class EdmondsKarpAlgorithm

    # Initializes Edmonds-Karp algorithm for a _graph_ with provided edges capacities map.
    #
    def initialize(graph, edge_capacities_map)
      raise NotDirectedError.new('Edmonds-Karp algorithm can only be applied to a directed graph') unless graph.directed?

      @graph = graph
      validate_edge_capacities(edge_capacities_map)
      @edge_capacities_map = NonNegativeEdgePropertiesMap.new(edge_capacities_map, true)
    end

    # Finds the maximum flow from the _source_ to the _sink_ in the graph.
    #
    # Returns flows map as a hash that maps each edge of the graph to a flow through that edge that is required to reach
    # the maximum total flow.
    #
    def maximum_flow(source, sink)
      raise ArgumentError.new("source and sink can't be equal") if source == sink

      @flow_map = Hash.new(0)
      @residual_capacity_map = lambda { |u, v| @edge_capacities_map.edge_property(u, v) - @flow_map[[u, v]] }

      loop do
        bfs = EdmondsKarpBFSIterator.new(@graph, source, sink, @residual_capacity_map)

        bfs.move_forward_until { bfs.color_map[sink] == :GRAY }

        if bfs.color_map[sink] == :WHITE
          break # no more augmenting paths
        else
          min_residual_capacity = INFINITY

          augmenting_path = [sink]

          while augmenting_path.first != source
            v = augmenting_path.first
            u = bfs.parents_map[v]

            augmenting_path.unshift(u)
            min_residual_capacity = [min_residual_capacity, @residual_capacity_map[u, v]].min
          end

          augmenting_path.each_cons(2) do |(uu, vv)|
            @flow_map[[uu, vv]] += min_residual_capacity
            @flow_map[[vv, uu]] -= min_residual_capacity
          end
        end
      end

      @flow_map
    end

    private

    def validate_edge_capacities(edge_capacities_map)
      @graph.each_edge do |u, v|
        raise ArgumentError.new("reverse edge for (#{u}, #{v}) is missing") unless @graph.has_edge?(v, u)
        validate_capacity(u, v, edge_capacities_map)
      end
    end

    def validate_capacity(u, v, edge_capacities_map)
      capacity         = get_capacity(u, v, edge_capacities_map)
      reverse_capacity = get_capacity(v, u, edge_capacities_map)

      validate_negative_capacity(u, v, capacity)
      validate_negative_capacity(v, u, reverse_capacity)

      raise ArgumentError.new("either (#{u}, #{v}) or (#{v}, #{u}) should have 0 capacity") unless [capacity, reverse_capacity].include?(0)
    end

    def get_capacity(u, v, edge_capacities_map)
      edge_capacities_map.fetch([u, v]) { raise ArgumentError.new("capacity for edge (#{u}, #{v}) is missing") }
    end

    def validate_negative_capacity(u, v, capacity)
      raise ArgumentError.new("capacity of edge (#{u}, #{v}) is negative") unless capacity >= 0
    end

    class EdmondsKarpBFSIterator < BFSIterator

      attr_accessor :parents_map

      def initialize(graph, start, stop, residual_capacities)
        super(graph, start)
        @residual_capacities = residual_capacities
        @stop_vertex = stop
      end

      def reset
        super
        @parents_map = {}
      end

      def follow_edge?(u, v)
        # follow only edges with positive residual capacity
        super && @residual_capacities[u, v] > 0
      end

      def handle_tree_edge(u, v)
        super
        @parents_map[v] = u
      end

    end # class EdmondsKarpBFSIterator

  end # class EdmondsKarpAlgorithm

  module Graph

    # Finds the maximum flow from the _source_ to the _sink_ in the graph.
    #
    # Returns flows map as a hash that maps each edge of the graph to a flow through that edge that is required to reach
    # the maximum total flow.
    #
    # For the method to work, the graph should be first altered so that for each directed edge (u, v) it contains reverse
    # edge (u, v). Capacities of the primary edges should be non-negative, while reverse edges should have zero capacity.
    #
    # Raises ArgumentError if the graph is not directed.
    #
    # Raises ArgumentError if a reverse edge is missing, edge capacity is missing, an edge has negative capacity, or a
    # reverse edge has positive capacity.
    #
    def maximum_flow(edge_capacities_map, source, sink)
      EdmondsKarpAlgorithm.new(self, edge_capacities_map).maximum_flow(source, sink)
    end

  end # module Graph

end
