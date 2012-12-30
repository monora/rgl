require 'test_helper'

require 'rgl/traversal'
require 'rgl/connected_components'
require 'rgl/adjacency'

include RGL

def graph_from_string(s)
  g = DirectedAdjacencyGraph.new(Array)
  s.split(/\n/).collect { |x| x.split(/->/) }.each do |a|
    from = a[0].strip
    a[1].split.each do |to|
      g.add_edge from, to
    end
  end
  g
end

class TestComponents < Test::Unit::TestCase

  def setup
    @dg   = DirectedAdjacencyGraph.new(Array)
    edges = [[1, 2], [2, 3], [2, 4], [4, 5], [1, 6], [6, 4]]
    edges.each do |(src, target)|
      @dg.add_edge(src, target)
    end
    @bfs = @dg.bfs_iterator(1)
    @dfs = @dg.dfs_iterator(1)

    @ug = AdjacencyGraph.new(Array)
    @ug.add_edges(*edges)

    @dg2 = graph_from_string(<<-END
a -> b f h
b -> c a
c -> d b
d -> e
e -> d
f -> g
g -> f d
h -> i
i -> h j e c
    END
    )
  end

  def test_connected_components
    ccs = []
    @ug.each_connected_component { |c| ccs << c }
    assert_equal(1, ccs.size)

    ccs = []
    @ug.add_edge 10, 11
    @ug.add_edge 33, 44
    @ug.each_connected_component { |c| ccs << c.sort }
    assert_equal([[10, 11], [1, 2, 3, 4, 5, 6], [33, 44]].sort, ccs.sort)
  end

  def test_strong_components
    vis = @dg2.strongly_connected_components

    assert_equal(4, vis.num_comp)

    res = vis.comp_map.to_a.sort.reduce({}) { |res, a|
      if res.key?(a[1])
        res[a[1]] << a[0]
      else
        res[a[1]] = [a[0]]
      end
      res
    }

    std_res = res.to_a.map {
        |a|
      [a[1][0], a[1]]
    }.sort

    assert_equal([["a", ["a", "b", "c", "h", "i"]], ["d", ["d", "e"]], ["f", ["f", "g"]], ["j", ["j"]]], std_res)
  end
end
