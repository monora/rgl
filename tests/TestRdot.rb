require 'test/unit'
require 'rgl/rdot'

class TestDot < Test::Unit::TestCase

  def test_bug_16125
    node = DOT::DOTNode.new({"label"=>"the_label"})
    dot = node.to_s
    assert_no_match(dot, /,/)
  end

  def assert_match(dot, pattern)
    assert(!(dot =~ pattern).nil?, "#{dot} doesn't match #{pattern}")
  end

  def assert_no_match(dot, pattern)
    assert((dot =~ pattern).nil?, "#{dot} shouldn't match #{pattern}")
  end
end
