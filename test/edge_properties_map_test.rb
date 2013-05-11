require 'test_helper'

require 'rgl/edge_properties_map'

include RGL

class TestEdgePropertiesMap < Test::Unit::TestCase

  def setup
    @edge_properties = {
        [1, 2] => 1,
        [2, 3] => 3,
        [1, 3] => 7
    }

    @edge_properties_lambda = lambda { |edge| @edge_properties[edge] }
  end

  def test_directed_graph
    properties_map = EdgePropertiesMap.new(@edge_properties, true)

    assert_equal(1, properties_map.edge_property(1, 2))
    assert_equal(3, properties_map.edge_property(2, 3))
    assert_equal(7, properties_map.edge_property(1, 3))

    assert_raise ArgumentError do
      properties_map.edge_property(2, 1)
    end
  end

  def test_undirected_graph
    properties_map = EdgePropertiesMap.new(@edge_properties, false)

    assert_equal(1, properties_map.edge_property(1, 2))
    assert_equal(3, properties_map.edge_property(2, 3))
    assert_equal(7, properties_map.edge_property(1, 3))

    assert_equal(1, properties_map.edge_property(2, 1))
    assert_equal(3, properties_map.edge_property(3, 2))
    assert_equal(7, properties_map.edge_property(3, 1))
  end

  def test_nil_properties
    assert_raise ArgumentError do
      EdgePropertiesMap.new(@edge_properties.merge([1, 4] => nil), false)
    end
  end

  def test_non_negative_properties_map
    assert_raise ArgumentError do
      NonNegativeEdgePropertiesMap.new(@edge_properties.merge([1, 4] => -2), false)
    end
  end

  def test_with_lambda
    properties_map = EdgePropertiesMap.new(@edge_properties_lambda, true)

    assert_equal(1, properties_map.edge_property(1, 2))
    assert_equal(3, properties_map.edge_property(2, 3))
    assert_equal(7, properties_map.edge_property(1, 3))
  end

end