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

# Tests for DOTPort
class TestDotPort < Test::Unit::TestCase
  def test_name
    port = DOTPort.new({'name' => 'test_name'})
    assert_equal('<test_name>', port.to_s)
  end

  def test_label
    port = DOTPort.new({'label' => 'test_label'})
    assert_equal('test_label', port.to_s)
  end

  def test_name_and_label
    port = DOTPort.new({'name' => 'test_name', 'label' => 'test_label'})
    assert_equal('<test_name> test_label', port.to_s)
  end

  def test_nested_ports
    port = DOTPort.new({'ports' => [DOTPort.new({'label' => 'a'}), DOTPort.new({'label' => 'b'})]})
    assert_equal('{a | b}', port.to_s)
  end

  def test_name_label_and_nested_ports
    port = DOTPort.new({'name' => 'test_name', 'label' => 'test_label', 'ports' => [DOTPort.new({'label' => 'a'}), DOTPort.new({'label' => 'b'})]})
    assert_equal('{a | b}', port.to_s)
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

  def test_name_without_label
    node = DOTNode.new({"name"=>"test_name"})
    dot = node.to_s
    assert_no_match(dot, /label/)
  end

  def test_no_label
    node = DOTNode.new({"shape"=>"ellipse"})
    dot = node.to_s
    assert_no_match(dot, /label/)
  end

  def test_Mrecord_no_label_no_ports
    node = DOTNode.new({"name" => "test_name", "shape"=>"Mrecord"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_no_match(dot, /label/)
  end

  def test_Mrecord_label_no_ports
    node = DOTNode.new({"name" => "test_name", "label" => "test_label", "shape"=>"Mrecord"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*"test_label"/)
  end

  def test_Mrecord_label_with_ports
    node = DOTNode.new({"name" => "test_name", "label" => "test_label", "shape"=>"Mrecord"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_Mrecord_no_label_with_ports
    node = DOTNode.new({"name" => "test_name", "shape"=>"Mrecord"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_record_no_label_no_ports
    node = DOTNode.new({"name" => "test_name", "shape"=>"record"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_no_match(dot, /label/)
  end

  def test_record_label_no_ports
    node = DOTNode.new({"name" => "test_name", "label" => "test_label", "shape"=>"record"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*"test_label"/)
  end

  def test_record_label_with_ports
    node = DOTNode.new({"name" => "test_name", "label" => "test_label", "shape"=>"record"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_record_no_label_with_ports
    node = DOTNode.new({"name" => "test_name", "shape"=>"record"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_no_shape_no_label_no_ports
    node = DOTNode.new({"name" => "test_name"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_no_match(dot, /shape\s*=\s/)
    assert_no_match(dot, /label\s*=\s*/)
  end

  def test_no_shape_no_label_with_ports
    node = DOTNode.new({"name" => "test_name"})
    node << DOTPort.new({"label" => "a"})
    node << DOTPort.new({"label" => "b"})
    dot = node.to_s
    assert_no_match(dot, /shape\s*=\s*record/)
    assert_no_match(dot, /label\s*=\s*/)
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

  def test_no_label
    edge = DOTEdge.new({"weight"=>"2"})
    dot = edge.to_s
    assert_no_match(dot, /label/)
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
