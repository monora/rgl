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

  # Module GraphXML adds to each class, including module MutableGraph, a class
  # method from_graphxml.
  #
  # Attention: Because append_features is used to provide the functionality,
  # GraphXML must be loaded before the concrete class including MutableGraph
  # is loaded.

  module GraphXML

    class MutableGraphParser

      include REXML::StreamListener

      attr_reader :graph

      def initialize (graph)
        @graph = graph
      end

      def tag_start (name, attrs)
        case name
        when 'edge'
          @graph.add_edge(attrs['source'], attrs['target'])
        when 'node'
          @graph.add_vertex(attrs['id'])
        end
      end

    end		# class MutableGraphParser
        
    def MutableGraph.append_features (includingClass)
      super

      # Create a new MutableGraph from the XML-Source _source_.

      def includingClass.from_graphxml (source)
        listener = MutableGraphParser.new(self.new)
        REXML::Document.parse_stream(source, listener)
        listener.graph
      end
    end

  end                           # module GraphXML
end                             # module RGL
