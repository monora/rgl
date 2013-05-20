require 'test_helper'

require 'rgl/bipartite'
require 'rgl/adjacency'

include RGL

class TestBipartite < Test::Unit::TestCase

  def test_bipartite_sets
    assert_equal([[1, 2, 3], [4, 5, 6]], bipartite_sets(AdjacencyGraph[1,5, 1,6, 2,4, 2,5, 3,4, 3,5, 3,6]))
  end

  def test_bipartite_sets_for_non_bipartite_graph
    assert_equal(nil, bipartite_sets(AdjacencyGraph[1,4, 1,5, 2,3, 2,4, 2,5, 3,5]))
  end

  def test_bipartite_sets_for_directed_graph
    assert_raise(NotUndirectedError, 'bipartite sets can only be found for an undirected graph') do
      DirectedAdjacencyGraph.new.bipartite_sets
    end
  end

  def test_bipartite_sets_for_bipartite_disconnected_graph
    assert_equal([[1, 3], [2, 4]], bipartite_sets(AdjacencyGraph[1,2, 3,4]))
  end

  def test_bipartite_sets_for_non_bipartite_disconnected_graph
    assert_equal(nil, bipartite_sets(AdjacencyGraph[1,2, 3,4, 4,5, 5,3]))
  end

  def test_bipartite
    assert(AdjacencyGraph[1,2, 2,3].bipartite?)
  end

  def test_not_bipartite
    assert(!AdjacencyGraph[1,2, 2,3, 3,1].bipartite?)
  end

  private

  def bipartite_sets(graph)
    sets = graph.bipartite_sets
    sets && sets.map { |set| set.sort }.sort
  end

end