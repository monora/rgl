module RGL

  class EdgeWeightsMap # :nodoc:

    def initialize(edge_weights_map, directed)
      @edge_weights_map = edge_weights_map
      @directed = directed

      check_weights
    end

    def edge_weight(u, v)
      if @directed
        weight = @edge_weights_map[[u, v]]
      else
        weight = @edge_weights_map[[u, v]] || @edge_weights_map[[v, u]]
      end

      validate_weight(weight, u, v)

      weight
    end

    private

    def check_weights
      @edge_weights_map.each { |(u, v), weight| validate_weight(weight, u, v) } if @edge_weights_map.respond_to?(:each)
    end

    def validate_weight(weight, u, v)
      report_missing_weight(weight, u, v)
    end

    def report_missing_weight(weight, u, v)
      raise ArgumentError.new("weight of edge (#{u}, #{v}) is not defined") unless weight
    end

  end # EdgeWeightsMap

  class NonNegativeEdgeWeightsMap < EdgeWeightsMap # :nodoc:

    private

    def validate_weight(weight, u, v)
      super
      report_negative_weight(weight, u, v)
    end

    def report_negative_weight(weight, u, v)
      raise ArgumentError.new("weight of edge (#{u}, #{v}) is negative") if weight < 0
    end

  end

end