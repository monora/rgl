# propertygraph.rb

require 'rgl/base'

module RGL

  # A PropertyGraph can attach properties as key value pairs to vertices and edges.
  #
  module PropertyGraph
    def put_vertex_property(v, key, value)
      raise NotImplementedError
    end

    def get_vertex_property(v, key)
      raise NotImplementedError
    end

    def put_edge_property(v, w, key, value)
      raise NotImplementedError
    end

    def get_edge_property(v, w, key)
      raise NotImplementedError
    end
  end
end # module RGL
