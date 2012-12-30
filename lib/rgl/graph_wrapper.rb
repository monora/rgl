module RGL

  module GraphWrapper # :nodoc:

    attr_accessor :graph

    # Creates a new GraphWrapper on _graph_.
    #
    def initialize(graph)
      @graph = graph
    end

  end # module GraphWrapper

end # RGL