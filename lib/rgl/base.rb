# base.rb
#
# Module RGL defines the namespace for all modules and classes of the graph
# library. The main module is RGL::Graph which defines the abstract behavior of
# all graphs in the library.

RGL_VERSION = "0.2.4"

require 'rgl/enumerable_ext'
require 'rgl/edge'
require 'rgl/graph'
require 'rgl/bidirectional'

module RGL
  class NotDirectedError   < RuntimeError; end
  class NotUndirectedError < RuntimeError; end
  class NoVertexError      < IndexError;   end
  class NoEdgeError        < IndexError;   end

  module Edge
  end
  module Graph
  end
  module BidirectionalGraph
  end

end

RGL::Edge.class_eval do
  include Edge
end

RGL::Graph.class_eval do
  include Graph
end

RGL::BidirectionalGraph.class_eval do
  include BidirectionalGraph
end

