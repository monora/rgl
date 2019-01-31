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
      dot   = graph.to_dot_graph.to_s

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

  def test_to_dot_digraph_with_options
      graph = RGL::DirectedAdjacencyGraph["a", "b"]

    begin
      edge_labels = {}
      graph.each_edge do |b, e|
        key              = "#{b}-#{e}"
        edge_labels[key] = "#{b} to #{e}"
      end
      
      vertex_fontcolors = {
        'a' => 'green',
        'b' => 'blue'
      }
      vertex_fontcolor_setting = Proc.new{|v| vertex_fontcolors[v]}
      vertex_settings          = {'fontcolor' => vertex_fontcolor_setting, 'fontsize' => 12}
      
      edge_label_setting = Proc.new{|b, e| edge_labels["#{b}-#{e}"]}
      edge_settings      = {'color' => 'red', 'label' => edge_label_setting}
      dot_options        = {'edge' => edge_settings,'vertex' => vertex_settings}
      dot                = graph.to_dot_graph(dot_options).to_s

      assert_match(dot, /a \[\n\s*fontcolor = green,\n\s*fontsize = 12,\n\s*label = a\n\s*/)
      assert_match(dot, /b \[\n\s*fontcolor = blue,\n\s*fontsize = 12,\n\s*label = a\n\s*/)
      assert_match(dot, /a -> b \[\n\s*color = red,\n\s*fontsize = 8,\n\s*label = \"a to b\"\n/)
    rescue
      puts "Graphviz not installed?"
    end
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
