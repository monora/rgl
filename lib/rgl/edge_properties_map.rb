module RGL

  class EdgePropertiesMap

    def initialize(edge_properties_map, directed)
      @edge_properties_map = edge_properties_map
      @directed = directed

      check_properties
    end

    def edge_property(u, v)
      if @directed
        property = @edge_properties_map[[u, v]]
      else
        property = @edge_properties_map[[u, v]] || @edge_properties_map[[v, u]]
      end

      validate_property(property, u, v)

      property
    end

    private

    def check_properties
      @edge_properties_map.each { |(u, v), property| validate_property(property, u, v) } if @edge_properties_map.respond_to?(:each)
    end

    def validate_property(property, u, v)
      report_missing_property(property, u, v)
    end

    def report_missing_property(property, u, v)
      raise ArgumentError.new("property of edge (#{u}, #{v}) is not defined") unless property
    end

  end # EdgePropertiesMap

  class NonNegativeEdgePropertiesMap < EdgePropertiesMap

    private

    def validate_property(property, u, v)
      super
      report_negative_property(property, u, v)
    end

    def report_negative_property(property, u, v)
      raise ArgumentError.new("property of edge (#{u}, #{v}) is negative") if property < 0
    end

  end

end