require 'test_helper'

require 'rgl/dijkstra'
require 'rgl/adjacency'

include RGL

class TestDijkstraIssue24 < Test::Unit::TestCase

  def setup
    @graph = RGL::AdjacencyGraph[2,53, 2,3, 3,8, 3,28, 3,39, 29,58, 8,35, 12,39, 10,29, 62,15, 15,32,  32,58, 58,44, 44,53]

  end

  def test_shortest_path_search
    assert_equal([53, 44, 58, 32, 15, 62], shortest_path(53, 62))
  end

  def shortest_path(v,w)
    @graph.dijkstra_shortest_path(Hash.new(1), v, w).inspect
  end

end