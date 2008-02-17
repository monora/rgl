require 'test/unit'
require 'rgl/rdot'

include DOT

# Add some helper methods to TestCase
class Test::Unit::TestCase

  # assert string matches regular expression
  def assert_match(dot, pattern)
    assert(!(dot =~ pattern).nil?, "#{dot} doesn't match #{pattern}")
  end

  # assert string doesn't match regular expression
  def assert_no_match(dot, pattern)
    assert((dot =~ pattern).nil?, "#{dot} shouldn't match #{pattern}")
  end

end

# Tests for DOTNode
class TestDotNode < Test::Unit::TestCase

  # bug 16125
  def test_1prop_0comma
    node = DOTNode.new({"label"=>"the_label"})
    dot = node.to_s
    assert_no_match(dot, /,/)
  end

  def test_2prop_1comma
    node = DOTNode.new({"label"=>"the_label", "shape"=>"ellipse"})
    dot = node.to_s
    assert_match(dot, /\[[^,]*,[^,]*\]/)
  end
end

# Tests for DOTEdge
class TestDotEdge < Test::Unit::TestCase

  def test_1prop_0comma
    edge = DOTEdge.new({"label"=>"the_label"})
    dot = edge.to_s
    assert_no_match(dot, /,/)
  end

  def test_2prop_1comma
    edge = DOTEdge.new({"label"=>"the_label", "weight"=>"2"})
    dot = edge.to_s
    assert_match(dot, /\[[^,]*,[^,]*\]/)
  end
end

# Tests for DOTSubgraph
class TestDotSubgraph < Test::Unit::TestCase
	def test_subgraph_statement
		subgraph = DOTSubgraph.new()
		dot = subgraph.to_s
		assert_match(dot, /^\s*subgraph /)
	end
end
