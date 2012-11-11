require 'test/unit'
require 'rgl/dot'

class TestDot < Test::Unit::TestCase

  def test_to_dot_graph
    graph = RGL::DirectedAdjacencyGraph[1,2]
    dot = graph.to_dot_graph.to_s
    assert_match(dot, /\{[^}]*\}/) # {...}
    assert_match(dot, /1\s*\[/) # node 1
    assert_match(dot, /2\s*\[/) # node 2
    assert_match(dot, /1\s*->\s*2/) # edge
  end

  def assert_match(dot, pattern)
    assert(!(dot =~ pattern).nil?, "#{dot} doesn't match #{pattern}")
  end
end
