# rdot.rb
# 
# $Id$
#
# This is a modified version of dot.rb from Dave Thomas's rdoc project.  I
# renamed it to rdot.rb to avoid collision with an installed rdoc/dot.
#
# It also supports undirected edges.

module DOT
    
  # These glogal vars are used to make nice graph source.

  $tab  = '    '
  $tab2 = $tab * 2
    
  # if we don't like 4 spaces, we can change it any time

  def change_tab (t)
    $tab  = t
    $tab2 = t * 2
  end
    
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
    
  # an element that has options ( node, edge, or graph )

  class DOTElement
    attr_accessor :name, :options

    def initialize (params = {}, option_list = [])
      @name   = params['name']   ? params['name']   : nil
      @options = {}
      option_list.each{ |i|
        @options[i] = params[i] if params[i]
      }
    end

    def each_option
      @options.each{ |i| yield i }
    end

    def each_option_pair
      @options.each_pair{ |key, val| yield key, val }
    end

    def quote_ID(id)
      # Return the ID verbatim if it looks like a name, a number, or HTML.
      return id if id =~ /^([[:alpha:]_][[:alnum:]_]*|-?(\.[[:digit:]]+|[[:digit:]]+(\.[[:digit:]]*)?)|<.*>)$/

      # Return a quoted version of the ID otherwise.
      '"' + id.gsub('\\', '\\\\\\\\').gsub('"', '\\\\"') + '"'
    end
    private :quote_ID

    def quote_label(label)
      # Return the label verbatim if it looks like a name, a number, or HTML.
      return label if label =~ /^([[:alpha:]_][[:alnum:]_]*|-?(\.[[:digit:]]+|[[:digit:]]+(\.[[:digit:]]*)?)|<.*>)$/

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
    private :quote_ID
  end


  # This is used when we build nodes that have shape=record or shape=Mrecord.
  # Ports don't have options. :)

  class DOTPort
    attr_accessor :name, :label, :ports

    def initialize (params = {})
      @name = params['name'] || ''
      @label = params['label'] || ''
      @ports = params['ports'] || []
    end

    def each_port
      @ports.each { |i| yield i }
    end

    def <<(port)
      @ports << port
    end
    alias :push :<<

    def pop
      @ports.pop
    end

    def to_s
      if @ports.empty? then
        n = @name.empty? ? '' : "<#{@name}>"
        n + ((n.empty? or label.empty?) ? '' : ' ') + label
      else
        '{' + @ports.collect {|p| p.to_s}.join(' | ') + '}'
      end
    end
  end
    
  # node element

  class DOTNode < DOTElement

    def initialize (params = {}, option_list = NODE_OPTS)
      super(params, option_list)
      @ports = params['ports'] ? params['ports'] : []
    end

    def each_port
      @ports.each { |i| yield i }
    end

    def << (port)
      @ports << port
    end
    alias :push :<<

    def pop
      @ports.pop
    end

    def to_s (t = '')
      label_option = nil
      if @options['shape'] =~ /^M?record$/ && !@ports.empty? then
        # Ignore the given label option in this case since the ports should each
        # provide their own name/label.
        label_option = t + $tab + "#{quote_ID('label')} = #{quote_ID(@ports.collect { |port| port.to_s }.join(" | "))}"
      elsif @options['label'] then
        # Otherwise, use the label when given one.
        label_option = t + $tab + "#{quote_ID('label')} = #{quote_label(@options['label'])}"
      end

      # Convert all the options except `label' and options with nil values
      # straight into name = value pairs.  Then toss out any resulting nil
      # entries in the final array.
      stringified_options = @options.collect do |name, val|
        unless name == 'label' || val.nil? then
          t + $tab + "#{quote_ID(name)} = #{quote_ID(val)}"
        end
      end.compact
      # Append the specially computed label option.
      stringified_options.push(label_option) unless label_option.nil?
      # Join them all together.
      stringified_options = stringified_options.join(",\n")

      # Put it all together into a single string with indentation and return the
      # result.
      if stringified_options.empty? then
        return t + quote_ID(@name) unless @name.nil?
        return nil
      else
        return t + (@name.nil? ? '' : quote_ID(@name) + " ") + "[\n" +
          stringified_options + "\n" +
          t + "]"
      end
    end

  end		# class DOTNode

  # This is a graph.

  class DOTGraph < DOTElement

    @nodes
    @dot_string

    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @nodes      = params['nodes'] ? params['nodes'] : []
      @dot_string = 'graph'
    end

    def each_node
      @nodes.each{ |i| yield i }
    end

    def << (thing)
      @nodes << thing
    end
    alias :push :<<

    def pop
      @nodes.pop
    end

    def to_s (t = '')
      hdr = t + @dot_string + (@name.nil? ? '' : ' ' + quote_ID(@name)) + " {\n"

      options = @options.to_a.collect do |name, val|
        unless val.nil? then
          if name == 'label' then
            t + $tab + "#{quote_ID(name)} = #{quote_label(val)}"
          else
            t + $tab + "#{quote_ID(name)} = #{quote_ID(val)}"
          end
        end
      end.compact.join( "\n" )

      nodes = @nodes.collect do |i|
        i.to_s( t + $tab )
      end.join( "\n\n" )
      hdr + options + "\n\n" + nodes + "\n" + t + "}"
    end

  end		# class DOTGraph

  # A digraph element is the same as graph, but has another header in dot
  # notation with an identifier of 'digraph' instead of 'graph'.

  class DOTDigraph < DOTGraph

    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @dot_string = 'digraph'
    end

  end		# class DOTDigraph

  # A subgraph element is the same as graph, but has another header in dot
  # notation with an identifier of 'subgraph' instead of 'graph'.

  class DOTSubgraph < DOTGraph

    def initialize (params = {}, option_list = GRAPH_OPTS)
      super(params, option_list)
      @dot_string = 'subgraph'
    end

  end		# class DOTSubgraph

  # This is an edge.

  class DOTEdge < DOTElement

    attr_accessor :from, :to

    def initialize (params = {}, option_list = EDGE_OPTS)
      super(params, option_list)
      @from = params['from'] ? params['from'] : nil
      @to   = params['to'] ? params['to'] : nil
    end
       
    def edge_link
      '--'
    end

    def to_s (t = '')
      stringified_options = @options.collect do |name, val|
        unless val.nil? then
          t + $tab + "#{quote_ID(name)} = #{quote_ID(val)}"
        end
      end.compact.join( ",\n" )

      f_s = @from || ''
      t_s = @to || ''
      if stringified_options.empty? then
        t + quote_ID(f_s) + ' ' + edge_link + ' ' + quote_ID(t_s)
      else
        t + quote_ID(f_s) + ' ' + edge_link + ' ' + quote_ID(t_s) + " [\n" +
          stringified_options + "\n" +
          t + "]"
      end
    end

  end		# class DOTEdge
          
  class DOTDirectedEdge < DOTEdge

    def edge_link
      '->'
    end

  end                           # class DOTDirectedEdge
end                             # module DOT
