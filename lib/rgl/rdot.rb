# This is a modified version of dot.rb from Dave Thomas's rdoc project.  I
# renamed it to rdot.rb to avoid collision with an installed rdoc/dot.
#
# It also supports undirected edges.

module RGL; module DOT

  # options for node declaration

  NODE_OPTS = [
    # attributes due to
    # http://www.graphviz.org/Documentation/dotguide.pdf
    # February 23, 2008
    'color', # default: black; node shape color
    'comment', # any string (format-dependent)
    'distortion', # default: 0.0; node distortion for shape=polygon
    'fillcolor', # default: lightgrey/black; node fill color
    'fixedsize', # default: false; label text has no affect on node size
    'fontcolor', # default: black; type face color
    'fontname', # default: Times-Roman; font family
    'fontsize', #default: 14; point size of label
    'group', # name of node's group
    'height', # default: .5; height in inches
    'label', # default: node name; any string
    'layer', # default: overlay range; all, id or id:id
    'orientation', # dafault: 0.0; node rotation angle
    'peripheries', # shape-dependent number of node boundaries
    'regular', # default:  false; force polygon to be regular
    'shape', # default: ellipse; node shape; see Section 2.1 and Appendix E
    'shapefile', # external EPSF or SVG custom shape file
    'sides', # default: 4; number of sides for shape=polygon
    'skew' , # default: 0.0; skewing of node for shape=polygon
    'style', # graphics options, e.g. bold, dotted, filled; cf. Section 2.3
    'URL', # URL associated with node (format-dependent)
    'width', # default: .75; width in inches
    'z', #default: 0.0; z coordinate for VRML output

    # maintained for backward compatibility or rdot internal
    'bottomlabel', # auxiliary label for nodes of shape M*
    'bgcolor',
    'rank',
    'toplabel' # auxiliary label for nodes of shape M*
  ]

  # options for edge declaration

  EDGE_OPTS = [
    'arrowhead', # default: normal; style of arrowhead at head end
    'arrowsize', # default: 1.0; scaling factor for arrowheads
    'arrowtail', # default: normal; style of arrowhead at tail end
    'color', # default: black; edge stroke color
    'comment', # any string (format-dependent)
    'constraint', # default: true use edge to affect node ranking
    'decorate', # if set, draws a line connecting labels with their edges
    'dir', # default: forward; forward, back, both, or none
    'fontcolor', # default: black type face color
    'fontname', # default: Times-Roman; font family
    'fontsize', # default: 14; point size of label
    'headlabel', # label placed near head of edge
    'headport', # n,ne,e,se,s,sw,w,nw
    'headURL', # URL attached to head label if output format is ismap
    'label', # edge label
    'labelangle', # default: -25.0; angle in degrees which head or tail label is rotated off edge
    'labeldistance', # default: 1.0; scaling factor for distance of head or tail label from node
    'labelfloat', # default: false; lessen constraints on edge label placement
    'labelfontcolor', # default: black; type face color for head and tail labels
    'labelfontname', # default: Times-Roman; font family for head and tail labels
    'labelfontsize', # default: 14 point size for head and tail labels
    'layer', # default: overlay range; all, id or id:id
    'lhead', # name of cluster to use as head of edge
    'ltail', # name of cluster to use as tail of edge
    'minlen', # default: 1 minimum rank distance between head and tail
    'samehead', # tag for head node; edge heads with the same tag are merged onto the same port
    'sametail', # tag for tail node; edge tails with the same tag are merged onto the same port
    'style', # graphics options, e.g. bold, dotted, filled; cf. Section 2.3
    'taillabel', # label placed near tail of edge
    'tailport', # n,ne,e,se,s,sw,w,nw
    'tailURL', # URL attached to tail label if output format is ismap
    'weight', # default: 1; integer cost of stretching an edge

    # maintained for backward compatibility or rdot internal
    'id'
  ]

  # options for graph declaration

  GRAPH_OPTS = [
    'bgcolor', # background color for drawing, plus initial fill color
    'center', # default: false; center draing on page
    'clusterrank', # default: local; may be "global" or "none"
    'color', # default: black; for clusters, outline color, and fill color if
             # fillcolor not defined
    'comment', # any string (format-dependent)
    'compound', # default: false; allow edges between clusters
    'concentrate', # default: false; enables edge concentrators
    'fillcolor', # default: black; cluster fill color
    'fontcolor', # default: black; type face color
    'fontname', # default: Times-Roman; font family
    'fontpath', # list of directories to search for fonts
    'fontsize', # default: 14; point size of label
    'label', # any string
    'labeljust', # default: centered; "l" and "r" for left- and right-justified
                 # cluster labels, respectively
    'labelloc', # default: top; "t" and "b" for top- and bottom-justified
                # cluster labels, respectively
    'layers', # id:id:id...
    'margin', # default: .5; margin included in page, inches
    'mclimit', # default: 1.0; scale factor for mincross iterations
    'nodesep', # default: .25; separation between nodes, in inches.
    'nslimit', # if set to "f", bounds network simplex iterations by
               # (f)(number of nodes) when setting x-coordinates
    'nslimit1', # if set to "f", bounds network simplex iterations by
                # (f)(number of nodes) when ranking nodes
    'ordering', # if "out" out edge order is preserved
    'orientation', # default: portrait; if "rotate" is not used and the value is
                   # "landscape", use landscape orientation
    'page', # unit of pagination, e.g. "8.5,11"
    'rank', # "same", "min", "max", "source", or "sink"
    'rankdir', # default: TB; "LR" (left to right) or "TB" (top to bottom)
    'ranksep', # default: .75; separation between ranks, in inches.
    'ratio', # approximate aspect ratio desired, "fill" or "auto"
    'samplepoints', # default: 8; number of points used to represent ellipses
                    # and circles on output
    'searchsize', # default: 30; maximum edges with negative cut values to check
                  # when looking for a minimum one during network simplex
    'size', # maximum drawing size, in inches
    'style', # graphics options, e.g. "filled" for clusters
    'URL', # URL associated with graph (format-dependent)

    # maintained for backward compatibility or rdot internal
    'layerseq'
  ]

  # Ancestor of Edge, Node, and Graph.
  class Element
    attr_accessor :name, :options

    def initialize (params = {}, option_list = []) # :nodoc:
      @name   = params['name']   ? params['name']   : nil
      @options = {}
      option_list.each{ |i|
        @options[i] = params[i] if params[i]
      }
    end

    private
      # Returns the string given in _id_ within quotes if necessary. Special
      # characters are escaped as necessary.
      def quote_ID(id)
        # Ensure that the ID is a string.
        id = id.to_s

        # Return the ID verbatim if it looks like a name, a number, or HTML.
        return id if id =~ /\A([[:alpha:]_][[:alnum:]_]*|-?(\.[[:digit:]]+|[[:digit:]]+(\.[[:digit:]]*)?)|<.*>)\Z/m and id[-1] != ?\n

        # Return a quoted version of the ID otherwise.
        '"' + id.gsub('\\', '\\\\\\\\').gsub('"', '\\\\"') + '"'
      end

      # Returns the string given in _label_ within quotes if necessary. Special
      # characters are escaped as necessary. Labels get special treatment in
      # order to handle embedded *\n*, *\r*, and *\l* sequences which are copied
      # into the new string verbatim.
      def quote_label(label)
        # Ensure that the label is a string.
        label = label.to_s

        # Return the label verbatim if it looks like a name, a number, or HTML.
        return label if label =~ /\A([[:alpha:]_][[:alnum:]_]*|-?(\.[[:digit:]]+|[[:digit:]]+(\.[[:digit:]]*)?)|<.*>)\Z/m and label[-1] != ?\n

        # Return a quoted version of the label otherwise.
        '"' + label.split(/(\\n|\\r|\\l)/).collect do |part|
          case part
          when "\\n", "\\r", "\\l"
            part
          else
            part.gsub('\\', '\\\\\\\\').gsub('"', '\\\\"').gsub("\n", '\\n')
          end
        end.join + '"'
      end
  end


  # Ports are used when a Node instance has its `shape' option set to
  # _record_ or _Mrecord_.  Ports can be nested.
  class Port
    attr_accessor :name, :label, :ports

    # Create a new port with either an optional name and label or a set of
    # nested ports.
    #
    # :call-seq:
    #   new(name = nil, label =  nil)
    #   new(ports)
    #
    # A +nil+ value for +name+ is valid; otherwise, it must be a String or it
    # will be interpreted as +ports+.
    def initialize (name_or_ports = nil, label = nil)
      if name_or_ports.nil? or name_or_ports.kind_of?(String) then
        @name = name_or_ports
        @label = label
        @ports = nil
      else
        @ports = name_or_ports
        @name = nil
        @label = nil
      end
    end

    # Returns a string representation of this port.  If ports is a non-empty
    # Enumerable, a nested ports representation is returned; otherwise, a
    # name-label representation is returned.
    def to_s
      if @ports.nil? or @ports.empty? then
        n = (name.nil? or name.empty?) ? '' : "<#{name}>"
        n + ((n.empty? or label.nil? or label.empty?) ? '' : ' ') + label.to_s
      else
        '{' + @ports.collect {|p| p.to_s}.join(' | ') + '}'
      end
    end
  end

  # A node representation.  Edges are drawn between nodes.  The rendering of a
  # node depends upon the options set for it.
  class Node < Element
    attr_accessor :ports

    # Creates a new Node with the _params_ Hash providing settings for all
    # node options. The _option_list_ parameter restricts those options to the
    # list of valid names it contains. The exception to this is the _ports_
    # option which, if specified, must be an Enumerable containing a list of
    # ports.
    def initialize (params = {}, option_list = NODE_OPTS)
      super(params, option_list)
      @ports = params['ports'] ? params['ports'] : []
    end

    # Returns a string representation of this node which is consumable by the
    # graphviz tools +dot+ and +neato+. The _leader_ parameter is used to indent
    # every line of the returned string, and the _indent_ parameter is used to
    # additionally indent nested items.
    def to_s (leader = '', indent = '    ')
      label_option = nil
      if @options['shape'] =~ /^M?record$/ && !@ports.empty? then
        # Ignore the given label option in this case since the ports should each
        # provide their own name/label.
        label_option = leader + indent + "#{quote_ID('label')} = #{quote_ID(@ports.collect { |port| port.to_s }.join(" | "))}"
      elsif @options['label'] then
        # Otherwise, use the label when given one.
        label_option = leader + indent + "#{quote_ID('label')} = #{quote_label(@options['label'])}"
      end

      # Convert all the options except `label' and options with nil values
      # straight into name = value pairs.  Then toss out any resulting nil
      # entries in the final array.
      stringified_options = @options.collect do |name, val|
        unless name == 'label' || val.nil? then
          leader + indent + "#{quote_ID(name)} = #{quote_ID(val)}"
        end
      end.compact
      # Append the specially computed label option.
      stringified_options.push(label_option) unless label_option.nil?
      # Join them all together.
      stringified_options = stringified_options.join(",\n")

      # Put it all together into a single string with indentation and return the
      # result.
      if stringified_options.empty? then
        return leader + quote_ID(@name) unless @name.nil?
        return nil
      else
        return leader + (@name.nil? ? '' : quote_ID(@name) + " ") + "[\n" +
          stringified_options + "\n" +
          leader + "]"
      end
    end

  end		# class Node

  # A graph representation. Whether or not it is rendered as directed or
  # undirected depends on which of the programs *dot* or *neato* is used to
  # process and render the graph.
  class Graph < Element

    # Creates a new Graph with the _params_ Hash providing settings for all
    # graph options. The _option_list_ parameter restricts those options to the
    # list of valid names it contains. The exception to this is the _elements_
    # option which, if specified, must be an Enumerable containing a list of
    # nodes, edges, and/or subgraphs.
    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @elements   = params['elements'] ? params['elements'] : []
      @dot_string = 'graph'
    end

    # Calls _block_ once for each node, edge, or subgraph contained by this
    # graph, passing the node, edge, or subgraph to the block.
    #
    # :call-seq:
    #   graph.each_element {|element| block} -> graph
    #
    def each_element (&block)
      @elements.each(&block)
      self
    end

    # Adds a new node, edge, or subgraph to this graph.
    #
    # :call-seq:
    #   graph << element -> graph
    #
    def << (element)
      @elements << element
      self
    end
    alias :push :<<

    # Removes the most recently added node, edge, or subgraph from this graph
    # and returns it.
    #
    # :call-seq:
    #   graph.pop -> element
    #
    def pop
      @elements.pop
    end

    # Returns a string representation of this graph which is consumable by the
    # graphviz tools +dot+ and +neato+. The _leader_ parameter is used to indent
    # every line of the returned string, and the _indent_ parameter is used to
    # additionally indent nested items.
    def to_s (leader = '', indent = '    ')
      hdr = leader + @dot_string + (@name.nil? ? '' : ' ' + quote_ID(@name)) + " {\n"

      options = @options.to_a.collect do |name, val|
        unless val.nil? then
          if name == 'label' then
            leader + indent + "#{quote_ID(name)} = #{quote_label(val)}"
          else
            leader + indent + "#{quote_ID(name)} = #{quote_ID(val)}"
          end
        end
      end.compact.join( "\n" )

      elements = @elements.collect do |element|
        element.to_s(leader + indent, indent)
      end.join("\n\n")
      hdr + (options.empty? ? '' : options + "\n\n") +
        (elements.empty? ? '' : elements + "\n") + leader + "}"
    end

  end		# class Graph

  # A digraph is a directed graph representation which is the same as a Graph
  # except that its header in dot notation has an identifier of _digraph_
  # instead of _graph_.
  class Digraph < Graph

    # Creates a new Digraph with the _params_ Hash providing settings for all
    # graph options.  The _option_list_ parameter restricts those options to the
    # list of valid names it contains. The exception to this is the _elements_
    # option which, if specified, must be an Enumerable containing a list of
    # nodes, edges, and/or subgraphs.
    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @dot_string = 'digraph'
    end

  end		# class Digraph

  # A subgraph is a nested graph element and is the same as a Graph except
  # that its header in dot notation has an identifier of _subgraph_ instead of
  # _graph_.
  class Subgraph < Graph

    # Creates a new Subgraph with the _params_ Hash providing settings for
    # all graph options.  The _option_list_ parameter restricts those options to
    # list of valid names it contains. The exception to this is the _elements_
    # option which, if specified, must be an Enumerable containing a list of
    # nodes, edges, and/or subgraphs.
    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @dot_string = 'subgraph'
    end

  end		# class Subgraph

  # This is an undirected edge representation.
  class Edge < Element

    # A node or subgraph reference or instance to be used as the starting point
    # for an edge.
    attr_accessor :from
    # A node or subgraph reference or instance to be used as the ending point
    # for an edge.
    attr_accessor :to

    # Creates a new Edge with the _params_ Hash providing settings for all
    # edge options.  The _option_list_ parameter restricts those options to the
    # list of valid names it contains.
    def initialize (params = {}, option_list = EDGE_OPTS)
      super(params, option_list)
      @from = params['from'] ? params['from'] : nil
      @to   = params['to'] ? params['to'] : nil
    end

    # Returns a string representation of this edge which is consumable by the
    # graphviz tools +dot+ and +neato+. The _leader_ parameter is used to indent
    # every line of the returned string, and the _indent_ parameter is used to
    # additionally indent nested items.
    def to_s (leader = '', indent = '    ')
      stringified_options = @options.collect do |name, val|
        unless val.nil? then
          leader + indent + "#{quote_ID(name)} = #{quote_ID(val)}"
        end
      end.compact.join( ",\n" )

      f_s = @from || ''
      t_s = @to || ''
      if stringified_options.empty? then
        leader + quote_ID(f_s) + ' ' + edge_link + ' ' + quote_ID(t_s)
      else
        leader + quote_ID(f_s) + ' ' + edge_link + ' ' + quote_ID(t_s) + " [\n" +
          stringified_options + "\n" +
          leader + "]"
      end
    end

    private
      def edge_link
        '--'
      end

  end		# class Edge

  # A directed edge representation otherwise identical to Edge.
  class DirectedEdge < Edge

    private
      def edge_link
        '->'
      end

  end                           # class DirectedEdge
end; end                        # module RGL; module DOT
