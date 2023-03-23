# dot.rb
#
# Minimal Dot support, based on Dave Thomas's dot module (included in rdoc).
# rdot.rb is a modified version which also contains support for undirected
# graphs.
#
# You need to have [GraphViz](https://www.graphviz.org) installed, because the
# functions in this modul execute the GraphViz executables _dot_ or _dotty_.

require 'rgl/rdot'

module RGL
  module Graph
    attr_reader :vertex_options, :edge_options

    # Returns a label for vertex v. Default is v.to_s
    def vertex_label(v)
      v.to_s
    end

    def vertex_id(v)
      v
    end

    # Set the configuration values for the given vertex
    def set_vertex_options(vertex, **options)
      @vertex_options ||= {}
      @vertex_options[vertex] ||= {}

      RGL::DOT::NODE_OPTS.each do |opt|
        @vertex_options[vertex][:"#{opt}"] = options[:"#{opt}"] if options.key?(:"#{opt}")
      end
    end

    # Set the configuration values for the given edge
    def set_edge_options(u, v, **options)
      edge = edge_class.new(u, v)
      @edge_options ||= {}
      @edge_options[edge] ||= {}

      RGL::DOT::EDGE_OPTS.each do |opt|
        @edge_options[edge][:"#{opt}"] = options[:"#{opt}"] if options.key?(:"#{opt}")
      end
    end

    # Return a {DOT::Digraph} for directed graphs or a {DOT::Graph} for an
    # undirected {Graph}. _params_ can contain any graph property specified in
    # rdot.rb.
    #
    def to_dot_graph(params = {})
      params['name'] ||= self.class.name.gsub(/:/, '_')
      fontsize       = params['fontsize'] ? params['fontsize'] : '8'
      graph          = (directed? ? DOT::Digraph : DOT::Graph).new(params)
      edge_class     = directed? ? DOT::DirectedEdge : DOT::Edge
      vertex_options = params['vertex'] || {}
      edge_options   = params['edge'] || {}

      each_vertex do |v|
        default_vertex_options = {
          'name'     => vertex_id(v),
          'fontsize' => fontsize,
          'label'    => vertex_label(v)
        }
        each_vertex_options = default_vertex_options.merge(vertex_options)



        vertex_options.each do |option, val|
          each_vertex_options[option] = if val.is_a?(Proc)
                                          if val.call(v).nil?
                                            nil
                                          elsif val.call(v).key?(:"#{option}")
                                            val.call(v)[:"#{option}"]
                                          end
                                        else
                                          val
                                        end
        end

          graph << DOT::Node.new(each_vertex_options)
        end

      each_edge do |u, v|
        default_edge_options = {
          'from'     => vertex_id(u),
          'to'       => vertex_id(v),
          'fontsize' => fontsize
        }
        each_edge_options = default_edge_options.merge(edge_options)

        edge_options.each do |option, val|
          each_edge_options[option] = if val.is_a?(Proc)
                                        if val.call(u, v).nil?
                                          nil
                                        elsif val.call(u, v).key?(:"#{option}")
                                          val.call(u, v)[:"#{option}"]
                                        end
                                      else
                                        val
                                      end
        end

            graph << edge_class.new(each_edge_options)
        end

      graph
    end

    # Output the DOT-graph to stream _s_.
    #
    def print_dotted_on(params = {}, s = $stdout)
      s << to_dot_graph(params).to_s << "\n"
    end

    # Call dotty[https://www.graphviz.org] for the graph which is written to the
    # file 'graph.dot' in the current directory.
    #
    def dotty(params = {})
      dotfile = "graph.dot"
      File.open(dotfile, "w") do |f|
        print_dotted_on(params, f)
      end
      unless system("dotty", dotfile)
        raise "Error executing dotty. Did you install GraphViz?"
      end
    end

    # Use dot[https://www.graphviz.org] to create a graphical representation of
    # the graph. Returns the filename of the graphics file.
    #
    def write_to_graphic_file(fmt = 'png', dotfile = "graph", options = {})
      src = dotfile + ".dot"
      dot = dotfile + "." + fmt

      File.open(src, 'w') do |f|
        f << self.to_dot_graph(options).to_s << "\n"
      end

      unless system("dot -T#{fmt} #{src} -o #{dot}")
        raise "Error executing dot. Did you install GraphViz?"
      end
      dot
    end

  end # module Graph

end # module RGL
