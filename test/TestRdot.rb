require 'test/unit'
require 'rgl/rdot'

include RGL

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

# Tests for DOT::Port
class TestDotPort < Test::Unit::TestCase
  def test_name
    port = DOT::Port.new()
    assert_equal('', port.to_s)

    port = DOT::Port.new('test_name')
    assert_equal('<test_name>', port.to_s)
  end

  def test_label
    port = DOT::Port.new(nil, 'test_label')
    assert_equal('test_label', port.to_s)
  end

  def test_name_and_label
    port = DOT::Port.new('test_name', 'test_label')
    assert_equal('<test_name> test_label', port.to_s)
  end

  def test_nested_ports
    port = DOT::Port.new([DOT::Port.new(nil, 'a'), DOT::Port.new(nil, 'b')])
    assert_equal('{a | b}', port.to_s)
  end

  def test_name_label_and_nested_ports
    port = DOT::Port.new('test_name', 'test_label')
    port.ports = [DOT::Port.new(nil, 'a'), DOT::Port.new(nil, 'b')]
    assert_equal('{a | b}', port.to_s)
  end
end

# Tests for DOT::Node
class TestDotNode < Test::Unit::TestCase

  def test_no_name
    node = DOT::Node.new()
    dot = node.to_s
    assert_nil(dot)
  end

  # bug 16125
  def test_1prop_0comma
    node = DOT::Node.new({"label"=>"the_label"})
    dot = node.to_s
    assert_no_match(dot, /,/)
  end

  def test_2prop_1comma
    node = DOT::Node.new({"label"=>"the_label", "shape"=>"ellipse"})
    dot = node.to_s
    assert_match(dot, /\[[^,]*,[^,]*\]/)
  end

  def test_name_without_label
    node = DOT::Node.new({"name"=>"test_name"})
    dot = node.to_s
    assert_no_match(dot, /label/)
  end

  def test_no_label
    node = DOT::Node.new({"shape"=>"ellipse"})
    dot = node.to_s
    assert_no_match(dot, /label/)
  end

  def test_Mrecord_no_label_no_ports
    node = DOT::Node.new({"name" => "test_name", "shape"=>"Mrecord"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_no_match(dot, /label/)
  end

  def test_Mrecord_label_no_ports
    node = DOT::Node.new({"name" => "test_name", "label" => "test_label", "shape"=>"Mrecord"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*test_label/)
  end

  def test_Mrecord_label_with_ports
    node = DOT::Node.new({"name" => "test_name", "label" => "test_label", "shape"=>"Mrecord"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_Mrecord_no_label_with_ports
    node = DOT::Node.new({"name" => "test_name", "shape"=>"Mrecord"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*Mrecord/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_record_no_label_no_ports
    node = DOT::Node.new({"name" => "test_name", "shape"=>"record"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_no_match(dot, /label/)
  end

  def test_record_label_no_ports
    node = DOT::Node.new({"name" => "test_name", "label" => "test_label", "shape"=>"record"})
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*test_label/)
  end

  def test_record_label_with_ports
    node = DOT::Node.new({"name" => "test_name", "label" => "test_label", "shape"=>"record"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_record_no_label_with_ports
    node = DOT::Node.new({"name" => "test_name", "shape"=>"record"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_match(dot, /shape\s*=\s*record/)
    assert_match(dot, /label\s*=\s*"a\s*|\s*b"/)
  end

  def test_no_shape_no_label_no_ports
    node = DOT::Node.new({"name" => "test_name"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_no_match(dot, /shape\s*=\s/)
    assert_no_match(dot, /label\s*=\s*/)
  end

  def test_no_shape_no_label_with_ports
    node = DOT::Node.new({"name" => "test_name"})
    node.ports << DOT::Port.new(nil, "a")
    node.ports << DOT::Port.new(nil, "b")
    dot = node.to_s
    assert_no_match(dot, /shape\s*=\s*record/)
    assert_no_match(dot, /label\s*=\s*/)
  end

  def test_name_quoting
    node = DOT::Node.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^"Name with spaces"$/)

    node = DOT::Node.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^"Name with \\"quotes\\""$/)

    node = DOT::Node.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^"Name with \\\\backslashes\\\\"$/)

    node = DOT::Node.new({"name" => "Name with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name with\nembedded\nnewlines".*\Z/m)

    node = DOT::Node.new({"name" => "Name_with_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name_with_trailing_newline\n".*\Z/m)

    node = DOT::Node.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^123.456$/)

    node = DOT::Node.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^.456$/)

    node = DOT::Node.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^-.456$/)

    node = DOT::Node.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^-456$/)

    node = DOT::Node.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^-123.456$/)

    node = DOT::Node.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>$/)
  end

  def test_label_quoting
    node = DOT::Node.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Label with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded\\nnewlines"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Label_with_a_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label_with_a_trailing_newline\\n"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOT::Node.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOT::Node.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOT::Node.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOT::Node.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOT::Node.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOT::Node.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOT::Node.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOT::Node.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOT::Node.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end
end

# Tests for DOT::Edge
class TestDotEdge < Test::Unit::TestCase

  def test_0prop
    edge = DOT::Edge.new({'from' => 'a', 'to' => 'b'})
    dot = edge.to_s
    assert_equal('a -- b', dot)
  end

  def test_1prop_0comma
    edge = DOT::Edge.new({"label"=>"the_label"})
    dot = edge.to_s
    assert_no_match(dot, /,/)
  end

  def test_2prop_1comma
    edge = DOT::Edge.new({"label"=>"the_label", "weight"=>"2"})
    dot = edge.to_s
    assert_match(dot, /\[[^,]*,[^,]*\]/)
  end

  def test_no_label
    edge = DOT::Edge.new({"weight"=>"2"})
    dot = edge.to_s
    assert_no_match(dot, /label/)
  end
end

# Tests for DOT::DirectedEdge
class TestDotDirectedEdge < Test::Unit::TestCase

  def test_0prop
    edge = DOT::DirectedEdge.new({'from' => 'a', 'to' => 'b'})
    dot = edge.to_s
    assert_equal('a -> b', dot)
  end

  def test_1prop_0comma
    edge = DOT::DirectedEdge.new({"label"=>"the_label"})
    dot = edge.to_s
    assert_no_match(dot, /,/)
  end

  def test_2prop_1comma
    edge = DOT::DirectedEdge.new({"label"=>"the_label", "weight"=>"2"})
    dot = edge.to_s
    assert_match(dot, /\[[^,]*,[^,]*\]/)
  end

  def test_no_label
    edge = DOT::DirectedEdge.new({"weight"=>"2"})
    dot = edge.to_s
    assert_no_match(dot, /label/)
  end
end

# Tests for DOT::Graph
class TestDotGraph < Test::Unit::TestCase
  def test_graph_statement
    graph = DOT::Graph.new()
    dot = graph.to_s
    assert_match(dot, /^\s*graph /)
  end

  def test_name_quoting
    node = DOT::Graph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^graph "Name with spaces" \{$/)

    node = DOT::Graph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^graph "Name with \\"quotes\\"" \{$/)

    node = DOT::Graph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^graph "Name with \\\\backslashes\\\\" \{$/)

    node = DOT::Graph.new({"name" => "Name with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name with\nembedded\nnewlines".*\Z/m)

    node = DOT::Graph.new({"name" => "Name_with_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name_with_trailing_newline\n".*\Z/m)

    node = DOT::Graph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^graph 123.456 \{$/)

    node = DOT::Graph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^graph .456 \{$/)

    node = DOT::Graph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^graph -.456 \{$/)

    node = DOT::Graph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^graph -456 \{$/)

    node = DOT::Graph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^graph -123.456 \{$/)

    node = DOT::Graph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^graph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOT::Graph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Label with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded\\nnewlines"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Label_with_a_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label_with_a_trailing_newline\\n"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOT::Graph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOT::Graph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOT::Graph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOT::Graph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_element_containment
    node1 = DOT::Node.new('name' => 'test_node1')
    node2 = DOT::Node.new('name' => 'test_node2')

    graph = DOT::Graph.new('name' => 'test_graph')
    assert_nil(graph.pop)
    assert_equal(graph, graph.push(node1))
    assert_equal(graph, graph << node2)
    graph.each_element do |element|
      assert([node1, node2].include?(element))
    end
    assert_equal(node2, graph.pop)
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)

    graph = DOT::Graph.new('name' => 'test_graph', 'elements' => [node1])
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)
  end
end

# Tests for DOT::Digraph
class TestDotDigraph < Test::Unit::TestCase
  def test_digraph_statement
    digraph = DOT::Digraph.new()
    dot = digraph.to_s
    assert_match(dot, /^\s*digraph /)
  end

  def test_name_quoting
    node = DOT::Digraph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with spaces" \{$/)

    node = DOT::Digraph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with \\"quotes\\"" \{$/)

    node = DOT::Digraph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^digraph "Name with \\\\backslashes\\\\" \{$/)

    node = DOT::Digraph.new({"name" => "Name with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name with\nembedded\nnewlines".*\Z/m)

    node = DOT::Digraph.new({"name" => "Name_with_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name_with_trailing_newline\n".*\Z/m)

    node = DOT::Digraph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^digraph 123.456 \{$/)

    node = DOT::Digraph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^digraph .456 \{$/)

    node = DOT::Digraph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^digraph -.456 \{$/)

    node = DOT::Digraph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^digraph -456 \{$/)

    node = DOT::Digraph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^digraph -123.456 \{$/)

    node = DOT::Digraph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^digraph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOT::Digraph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Label with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded\\nnewlines"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Label_with_a_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label_with_a_trailing_newline\\n"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOT::Digraph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOT::Digraph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOT::Digraph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_element_containment
    node1 = DOT::Node.new('name' => 'test_node1')
    node2 = DOT::Node.new('name' => 'test_node2')

    graph = DOT::Digraph.new('name' => 'test_graph')
    assert_nil(graph.pop)
    assert_equal(graph, graph.push(node1))
    assert_equal(graph, graph << node2)
    graph.each_element do |element|
      assert([node1, node2].include?(element))
    end
    assert_equal(node2, graph.pop)
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)

    graph = DOT::Digraph.new('name' => 'test_graph', 'elements' => [node1])
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)
  end
end

# Tests for DOT::Subgraph
class TestDotSubgraph < Test::Unit::TestCase
  def test_subgraph_statement
    subgraph = DOT::Subgraph.new()
    dot = subgraph.to_s
    assert_match(dot, /^\s*subgraph /)
  end

  def test_name_quoting
    node = DOT::Subgraph.new({"name" => "Name with spaces"})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with spaces" \{$/)

    node = DOT::Subgraph.new({"name" => "Name with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with \\"quotes\\"" \{$/)

    node = DOT::Subgraph.new({"name" => "Name with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /^subgraph "Name with \\\\backslashes\\\\" \{$/)

    node = DOT::Subgraph.new({"name" => "Name with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name with\nembedded\nnewlines".*\Z/m)

    node = DOT::Subgraph.new({"name" => "Name_with_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /\A.*"Name_with_trailing_newline\n".*\Z/m)

    node = DOT::Subgraph.new({"name" => "123.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph 123.456 \{$/)

    node = DOT::Subgraph.new({"name" => ".456"})
    dot = node.to_s
    assert_match(dot, /^subgraph .456 \{$/)

    node = DOT::Subgraph.new({"name" => "-.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -.456 \{$/)

    node = DOT::Subgraph.new({"name" => "-456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -456 \{$/)

    node = DOT::Subgraph.new({"name" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /^subgraph -123.456 \{$/)

    node = DOT::Subgraph.new({"name" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /^subgraph <html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html> \{$/)
  end

  def test_label_quoting
    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Label with spaces"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with spaces"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Label with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\"quotes\\""/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Label with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with \\\\backslashes\\\\"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Label with\nembedded\nnewlines"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label with\\nembedded\\nnewlines"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Label_with_a_trailing_newline\n"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Label_with_a_trailing_newline\\n"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Left justified label\\l"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Left justified label\\l"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "Right justified label\\r"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*"Right justified label\\r"/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*123.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => ".456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "-.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "-456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-456/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*-123.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "label" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /label\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_option_quoting
    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "Comment with spaces"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with spaces"/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "Comment with \"quotes\""})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\"quotes\\""/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "Comment with \\backslashes\\"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*"Comment with \\\\backslashes\\\\"/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*123.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => ".456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "-.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "-456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-456/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "-123.456"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*-123.456/)

    node = DOT::Subgraph.new({"name" => "test_name", "comment" => "<html><head><title>test</title></head>\n<body>text</body></html>"})
    dot = node.to_s
    assert_match(dot, /comment\s*=\s*<html><head><title>test<\/title><\/head>\n<body>text<\/body><\/html>/)
  end

  def test_element_containment
    node1 = DOT::Node.new('name' => 'test_node1')
    node2 = DOT::Node.new('name' => 'test_node2')

    graph = DOT::Subgraph.new('name' => 'test_graph')
    assert_nil(graph.pop)
    assert_equal(graph, graph.push(node1))
    assert_equal(graph, graph << node2)
    graph.each_element do |element|
      assert([node1, node2].include?(element))
    end
    assert_equal(node2, graph.pop)
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)

    graph = DOT::Subgraph.new('name' => 'test_graph', 'elements' => [node1])
    assert_equal(node1, graph.pop)
    assert_nil(graph.pop)
  end
end
