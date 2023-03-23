require 'test_helper'

require 'rgl/dot'
require 'rgl/adjacency'

class TestDot < Test::Unit::TestCase

  def assert_match(dot, pattern)
    assert(!(dot =~ pattern).nil?, "#{dot} doesn't match #{pattern}")
  end

  def test_to_dot_digraph
    graph = RGL::DirectedAdjacencyGraph["a", "b"]

    begin
      dot  = graph.to_dot_graph.to_s

      first_vertex_id = "a"
      second_vertex_id = "b"

      assert_match(dot, /\{[^}]*\}/) # {...}
      assert_match(dot, /#{first_vertex_id}\s*\[/)  # node 1
      assert_match(dot, /label\s*=\s*a/)            # node 1 label
      assert_match(dot, /#{second_vertex_id}\s*\[/) # node 2
      assert_match(dot, /label\s*=\s*b/)            # node 2 label
      assert_match(dot, /#{first_vertex_id}\s*->\s*#{second_vertex_id}/) # edge
    rescue
      puts "Graphviz not installed?"
    end
  end

  def test_dot_digraph_with_complicated_options
    graph = RGL::DirectedAdjacencyGraph['a', 'b', 'c', 'd']

    graph.set_vertex_options('a', label: 'This is A', shape: 'box3d', fontcolor: 'green', fontsize: 16)
    graph.set_vertex_options('b', label: 'This is B', shape: 'tab', fontcolor: 'red', fontsize: 14)
    graph.set_vertex_options('c', shape: 'tab', fontcolor: 'blue')

    graph.add_edge('a', 'b')
    graph.add_edge('a', 'c')
    graph.set_edge_options('a', 'b', label: 'NotCapitalEdge', style: 'dotted', direction: 'back', color: 'magenta')
    graph.set_edge_options('a', 'c', weight: 5, color: 'blue')

    graph_options = {
      "rankdir"  => "LR",
      "labelloc" => "t",
      "label"    => "Graph\n (generated #{Time.now.utc})"
    }

    dot = graph.to_dot_graph(graph_options).to_s

    assert_match(dot, /labelloc = t\n\s*/)
    assert_match(dot, /rankdir = LR\n\s*/)
    assert_match(dot, /a \[\n\s*fontcolor = green,\n\s*fontsize = 16,\n\s*shape = box3d,\n\s*label = "This is A"\n\s*/)
    assert_match(dot, /b \[\n\s*fontcolor = red,\n\s*fontsize = 14,\n\s*shape = tab,\n\s*label = "This is B"\n\s*/)
    assert_match(dot, /a -> b \[\n\s*color = magenta,\n\s*fontsize = 8,\n\s*label = NotCapitalEdge,\n\s*style = dotted\n\s*/)
  end

  def test_to_dot_graph
    graph = RGL::AdjacencyGraph["a", "b"]
    def graph.vertex_label(v)
      "label-"+v.to_s
    end

    def graph.vertex_id(v)
      "id-"+v.to_s
    end
    graph.write_to_graphic_file
  end

  def test_dot2015_options
    graph = RGL::DirectedAdjacencyGraph['a', 'b', 'c', 'd']

    graph.set_vertex_options('a', label: 'This is A', penwidth: 3.0)
    graph.set_vertex_options('b', label: 'This is B', penwdith: 4.0, tooltip: 'This is the B tooltip')
    graph.set_vertex_options('c', shape: 'tab', fontcolor: 'blue')

    graph.add_edge('a', 'b')
    graph.add_edge('a', 'c')
    graph.set_edge_options('a', 'b', style: 'dotted', dir: 'back', headtooltip: "Arrowhead tooltip")
    graph.set_edge_options('a', 'c', penwidth: 5, color: 'blue')

    get_vertex_setting = proc { |v| graph.vertex_options[v] }
    get_edge_setting = proc { |u, v| graph.edge_options[graph.edge_class.new(u, v)] }

    # To configure more options, add the respective keys and the proc call
    # Then provide the respective key:value to set_vertex_options
    # Any hard coded values for a key will be applied to all nodes
    vertex_options = {
      'label'     => get_vertex_setting,
      'shape'     => get_vertex_setting,
      'fontcolor' => get_vertex_setting,
      'penwidth'  => get_vertex_setting,
      'tooltip'   => get_vertex_setting
    }

    # To configure more options, add the respective keys and the proc call
    # Then provide the respective key:value to set_edge_options
    # Any hard coded values for a key will be applied to all edges
    edge_options = {
      'label'       => get_edge_setting,
      'dir'         => get_edge_setting,
      'color'       => get_edge_setting,
      'style'       => get_edge_setting,
      'headtooltip' => get_edge_setting,
      'penwidth'    => get_edge_setting
    }

    dot_options = { 'edge' => edge_options, 'vertex' => vertex_options }
    dot = graph.to_dot_graph(dot_options).to_s

    assert_match(dot, /a \[\n\s*fontsize = 8,\n\s*penwidth = 3.0,\n\s*label = "This is A"\n\s*/)
    assert_match(dot, /b \[\n\s*fontsize = 8,\n\s*tooltip = "This is the B tooltip",\n\s*label = "This is B"\n\s*/)
    assert_match(dot, /a -> b \[\n\s*dir = back,\n\s*fontsize = 8,\n\s*headtooltip = "Arrowhead tooltip",\n\s*style = dotted\n\s*/)
    assert_match(dot, /a -> c \[\n\s*color = blue,\n\s*fontsize = 8,\n\s*penwidth = 5\n\s*/)
  end
end
