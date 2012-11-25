# dot.rb
#
# $Id$
#
# Minimal Dot support, based on Dave Thomas's dot module (included in rdoc).
# rdot.rb is a modified version which also contains support for undirected
# graphs.

require 'rgl/rdot'

module RGL

  module Graph

    # Return a RGL::DOT::Digraph for directed graphs or a DOT::Graph for an
    # undirected Graph. _params_ can contain any graph property specified in
    # rdot.rb.
    #
    def to_dot_graph(params = {})
      params['name'] ||= self.class.name.gsub(/:/, '_')
      fontsize       = params['fontsize'] ? params['fontsize'] : '8'
      graph          = (directed? ? DOT::Digraph : DOT::Graph).new(params)
      edge_class     = directed? ? DOT::DirectedEdge : DOT::Edge

      each_vertex do |v|
        name = v.to_s
        graph << DOT::Node.new(
            'name'     => name,
            'fontsize' => fontsize,
            'label'    => name
        )
      end

      each_edge do |u, v|
        graph << edge_class.new(
            'from'     => u.to_s,
            'to'       => v.to_s,
            'fontsize' => fontsize
        )
      end

      graph
    end

    # Output the DOT-graph to stream _s_.
    #
    def print_dotted_on(params = {}, s = $stdout)
      s << to_dot_graph(params).to_s << "\n"
    end

    # Call dotty[http://www.graphviz.org] for the graph which is written to the
    # file 'graph.dot' in the current directory.
    #
    def dotty(params = {})
      dotfile = "graph.dot"
      File.open(dotfile, "w") do |f|
        print_dotted_on(params, f)
      end
      system("dotty", dotfile)
    end

    # Use dot[http://www.graphviz.org] to create a graphical representation of
    # the graph. Returns the filename of the graphics file.
    #
    def write_to_graphic_file(fmt='png', dotfile="graph")
      src = dotfile + ".dot"
      dot = dotfile + "." + fmt

      File.open(src, 'w') do |f|
        f << self.to_dot_graph.to_s << "\n"
      end

      system("dot -T#{fmt} #{src} -o #{dot}")
      dot
    end

  end # module Graph

end # module RGL
