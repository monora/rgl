# This file contains minimal support for creating RGL graphs from the
# GraphML[http://www.graphdrawing.org/graphml] format. The main purpose is to
# have a rich set of example graphs to have some more tests.
#
# See the examples directory which contains a subdirectory _north_ with the
# Graph catalog GraphViz[http://www.research.att.com/sw/tools/graphviz/refs.html].
#
# We use REXML::StreamListener from the
# REXML[http://www.germane-software.com/software/rexml]library to parse the graphml files.

require 'rgl/mutable'
require 'rexml/document'
require 'rexml/streamlistener'

module RGL
  # Module GraphXML adds to each class including module MutableGraph a class
  # method from_graphxml.
  #
  # Attention: Because append_features is used to provide the
  # functionality GraphXML must be loaded before the concrete class
  # implementing including MutableGraph is loaded.
  module GraphXML
	class MutableGraphParser
	  include REXML::StreamListener
	  attr_reader :graph
	  def initialize(graph)
		@graph = graph
	  end

	  def tag_start(name, attrs)
		case name
		when 'edge'
		  @graph.add_edge(attrs['source'],
						  attrs['target'])
		when 'node'
		  @graph.add_vertex(attrs['id'])
		end
	  end
	end
	
	def MutableGraph.append_features(includingClass)
	  super

	  # Create a new MutableGraph from the XML-Source _source_.
	  def includingClass.from_graphxml(source)
		listener = MutableGraphParser.new(self.new)
		REXML::Document.parse_stream(source, listener)
		listener.graph
	  end
	end
  end
end
