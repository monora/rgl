# graphxml.rb
#
# This file contains minimal support for creating RGL graphs from the GraphML
# format (see http://www.graphdrawing.org/graphml).  The main purpose is to
# have a rich set of example graphs to have some more tests.
#
# See the examples directory, which contains a subdirectory _north_ with the
# Graph catalog GraphViz (see
# http://www.research.att.com/sw/tools/graphviz/refs.html).
#
# We use REXML::StreamListener from the REXML library
# (http://www.germane-software.com/software/rexml) to parse the grapml files.

require 'rgl/mutable'
require 'rexml/document'
require 'rexml/streamlistener'

module RGL
  module MutableGraph
    # Used to parse a subset of GraphML into an RGL graph implementation.
    class MutableGraphParser
      include REXML::StreamListener

      # First resets +graph+ to be empty and stores a reference for use with
      # #tag_start.
      def initialize (graph)
        @graph = graph
        @graph.remove_vertices(@graph.vertices)
      end

      # Processes incoming edge and node elements from GraphML in order to
      # populate the graph given to #new.
      def tag_start (name, attrs)
        case name
        when 'edge'
          @graph.add_edge(attrs['source'], attrs['target'])
        when 'node'
          @graph.add_vertex(attrs['id'])
        end
      end
    end		# class MutableGraphParser

    # Initializes an RGL graph from a subset of the GraphML format given in
    # +source+ (see http://www.graphdrawing.org/graphml).
    def from_graphxml(source)
      listener = MutableGraphParser.new(self)
      REXML::Document.parse_stream(source, listener)
      self
    end
  end                           # module MutableGraph
end                             # module RGL
