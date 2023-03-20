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

    set_vertex_options('a', label: 'This is A', shape: 'box3d', fontcolor: 'green', fontsize: 16)
    set_vertex_options('b', label: 'This is B', shape: 'tab', fontcolor: 'red', fontsize: 14)
    set_vertex_options('c', shape: 'tab', fontcolor: 'blue')

    graph.add_edge('a', 'b')
    graph.add_edge('a', 'c')
    set_edge_options('a-b', label: 'NotCapitalEdge', style: 'dotted', direction: 'back', color: 'yellow')
    set_edge_options('a-c', weight: 5, color: 'blue')

    get_vertex_setting = proc { |v| @vertex_options[v] }
    get_edge_setting = proc { |b, e| @edge_options["#{b}-#{e}"] }

    # To configure more options, add the respective keys and the proc call
    # Then provide the respective key:value to set_vertex_options
    # Any hard coded values for a key will be applied to all nodes
    vertex_options = {
      'fontname'  => 'Calibri',
      'label'     => get_vertex_setting,
      'shape'     => get_vertex_setting,
      'fontcolor' => get_vertex_setting,
      'fontsize'  => get_vertex_setting
    }

    # To configure more options, add the respective keys and the proc call
    # Then provide the respective key:value to set_edge_options
    # Any hard coded values for a key will be applied to all edges
    edge_options = {
      'label'      => get_edge_setting,
      'dir'        => get_edge_setting,
      'color'      => get_edge_setting,
      'style'      => get_edge_setting,
      'weight'     => get_edge_setting,
      'constraint' => get_edge_setting,
      'headlabel'  => get_edge_setting,
      'taillabel'  => get_edge_setting
    }

    dot_options = { 'edge' => edge_options, 'vertex' => vertex_options }
    dot = graph.to_dot_graph(dot_options).to_s

    assert_match(dot, /a \[\n\s*fontcolor = green,\n\s*fontname = Calibri,\n\s*fontsize = 16,\n\s*shape = box3d,\n\s*label = "This is A"\n\s*/)
    assert_match(dot, /b \[\n\s*fontcolor = red,\n\s*fontname = Calibri,\n\s*fontsize = 14,\n\s*shape = tab,\n\s*label = "This is B"\n\s*/)
    assert_match(dot, /a -> b \[\n\s*color = yellow,\n\s*fontsize = 8,\n\s*label = NotCapitalEdge,\n\s*style = dotted\n\s*/)
  end

  def test_to_dot_graph
    graph = RGL::AdjacencyGraph["a", "b"]
    def graph.vertex_label(v)
      "label-"+v.to_s
    end

    def graph.vertex_id(v)
      "id-"+v.to_s
    end
    begin
      graph.write_to_graphic_file
    rescue
      puts "Graphviz not installed?"
    end
  end
end
