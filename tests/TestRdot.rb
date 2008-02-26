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
    assert_match(dot, /label\s*=\s*test_label/)
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
    assert_match(dot, /label\s*=\s*test_label/)
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

  def test_name_quoting
    node = DOTNode.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^"Name with spaces"$/)

    node = DOTNode.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^"Name with \\"quotes\\""$/)

    node = DOTNode.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^"Name with \\\\backslashes\\\\"$/)

    node = DOTNode.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^123.456$/)

    node = DOTNode.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^.456$/)

    node = DOTNode.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^-.456$/)

    node = DOTNode.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^-456$/)

    node = DOTNode.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^-123.456$/)

    node = DOTNode.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>$/)
  end

  def test_label_quoting
    node = DOTNode.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOTNode.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOTNode.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOTNode.new({"name" => "test_name", "label" => "Label with\nembedded newline"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded newline"/)

    node = DOTNode.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOTNode.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOTNode.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOTNode.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOTNode.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOTNode.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOTNode.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOTNode.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOTNode.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOTNode.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOTNode.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOTNode.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOTNode.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOTNode.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOTNode.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOTNode.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOTNode.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
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

# Tests for DOTGraph
class TestDotGraph < Test::Unit::TestCase
  def test_graph_statement
    graph = DOTGraph.new()
    dot = graph.to_s
    assert_match(dot, /^\s*graph /)
  end

  def test_name_quoting
    node = DOTGraph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^graph "Name with spaces" \{$/)

    node = DOTGraph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^graph "Name with \\"quotes\\"" \{$/)

    node = DOTGraph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^graph "Name with \\\\backslashes\\\\" \{$/)

    node = DOTGraph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^graph 123.456 \{$/)

    node = DOTGraph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^graph .456 \{$/)

    node = DOTGraph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^graph -.456 \{$/)

    node = DOTGraph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^graph -456 \{$/)

    node = DOTGraph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^graph -123.456 \{$/)

    node = DOTGraph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^graph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOTGraph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOTGraph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOTGraph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOTGraph.new({"name" => "test_name", "label" => "Label with\nembedded newline"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded newline"/)

    node = DOTGraph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOTGraph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOTGraph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOTGraph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOTGraph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOTGraph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOTGraph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOTGraph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOTGraph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOTGraph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOTGraph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end
end

# Tests for DOTDigraph
class TestDotDigraph < Test::Unit::TestCase
  def test_digraph_statement
    digraph = DOTDigraph.new()
    dot = digraph.to_s
    assert_match(dot, /^\s*digraph /)
  end

  def test_name_quoting
    node = DOTDigraph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with spaces" \{$/)

    node = DOTDigraph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with \\"quotes\\"" \{$/)

    node = DOTDigraph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with \\\\backslashes\\\\" \{$/)

    node = DOTDigraph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^digraph 123.456 \{$/)

    node = DOTDigraph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^digraph .456 \{$/)

    node = DOTDigraph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^digraph -.456 \{$/)

    node = DOTDigraph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^digraph -456 \{$/)

    node = DOTDigraph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^digraph -123.456 \{$/)

    node = DOTDigraph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^digraph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOTDigraph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "Label with\nembedded newline"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded newline"/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOTDigraph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOTDigraph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOTDigraph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOTDigraph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end
end

# Tests for DOTSubgraph
class TestDotSubgraph < Test::Unit::TestCase
  def test_subgraph_statement
    subgraph = DOTSubgraph.new()
    dot = subgraph.to_s
    assert_match(dot, /^\s*subgraph /)
  end

  def test_name_quoting
    node = DOTSubgraph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with spaces" \{$/)

    node = DOTSubgraph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with \\"quotes\\"" \{$/)

    node = DOTSubgraph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with \\\\backslashes\\\\" \{$/)

    node = DOTSubgraph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph 123.456 \{$/)

    node = DOTSubgraph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^subgraph .456 \{$/)

    node = DOTSubgraph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -.456 \{$/)

    node = DOTSubgraph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -456 \{$/)

    node = DOTSubgraph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -123.456 \{$/)

    node = DOTSubgraph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^subgraph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOTSubgraph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "Label with\nembedded newline"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded newline"/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOTSubgraph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOTSubgraph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOTSubgraph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end
end
