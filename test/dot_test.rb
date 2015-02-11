require 'test_helper'

require 'rgl/dot'
require 'rgl/adjacency'

class TestDot < Test::Unit::TestCase

  def assert_match(dot, pattern)
    assert(!(dot =~ pattern).nil?, "#{dot} doesn't match #{pattern}")
  end

  def test_to_dot_digraph
    graph = RGL::DirectedAdjacencyGraph[1, 2]
    dot   = graph.to_dot_graph.to_s

    first_vertex_id = 1.object_id
    second_vertex_id = 2.object_id
    
    assert_match(dot, /\{[^}]*\}/) # {...}
    assert_match(dot, /#{first_vertex_id}\s*\[/)  # node 1
    assert_match(dot, /label\s*=\s*1/)            # node 1 label
    assert_match(dot, /#{second_vertex_id}\s*\[/) # node 2
    assert_match(dot, /label\s*=\s*2/)            # node 2 label
    assert_match(dot, /#{first_vertex_id}\s*->\s*#{second_vertex_id}/) # edge
  end

  def test_to_dot_graph
    graph = RGL::AdjacencyGraph[1, 2]
    dot   = graph.write_to_graphic_file
  end
end
