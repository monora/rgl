require 'stream'

require 'rgl/graph_wrapper'

module RGL

  # A GraphIterator is the abstract basis for all Iterators on graphs.
  # Each graph iterator should implement the protocol defined in module Stream.
  #
  module GraphIterator
    include Stream
    include GraphWrapper
  end

end # RGL