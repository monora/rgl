$LOAD_PATH << "../lib"
require 'test/unit'
require 'rgl/adjacency'
require 'test_helper'

include RGL

class TestCycles < Test::Unit::TestCase

  def setup
    @dg = DirectedAdjacencyGraph.new(Array)
    edges = [[1,2],[2,2],[2,3],[3,4],[4,5],[5,1],[6,4],[6,6],[1,4],[7,7],[7,7]]
    edges.each do |(src,target)| 
      @dg.add_edge(src, target)
    end

    @ug = AdjacencyGraph.new(Array)
    @ug.add_edges(*edges)
  end

  # Helper for testing for different permutations of a cycle
  def contains_cycle?(cycles,cycle)
    cycle.size.times do |i|
      return true if cycles.include?(cycle)
      cycle = cycle[1..-1] + [cycle[0]]
    end
  end

  def test_cycles
    d_cycles = @dg.cycles
    assert_equal 6, d_cycles.size
    assert d_cycles.include?([6])
    assert d_cycles.include?([7])
    assert d_cycles.include?([2])
    assert contains_cycle?(d_cycles, [1,4,5])
    assert contains_cycle?(d_cycles, [1,2,3,4,5])
  
    assert_equal 5, DirectedAdjacencyGraph.new(Set, @dg).cycles.size

    u_cycles = AdjacencyGraph.new(Set, @dg).cycles.sort

    assert u_cycles.include?([2])
    assert u_cycles.include?([6])
    assert u_cycles.include?([7])
    assert contains_cycle?(u_cycles, [1,2,3,4,5])
    assert contains_cycle?(u_cycles, [1,5,4,3,2])
    assert contains_cycle?(u_cycles, [1,4,3,2])
    assert contains_cycle?(u_cycles, [1,4,5])
    assert contains_cycle?(u_cycles, [1,5,4])
    assert contains_cycle?(u_cycles, [1,5])
    assert contains_cycle?(u_cycles, [1,2])
    assert contains_cycle?(u_cycles, [1,2,3,4])
    assert contains_cycle?(u_cycles, [2,3])
    assert contains_cycle?(u_cycles, [1,4])
    assert contains_cycle?(u_cycles, [3,4])
    assert contains_cycle?(u_cycles, [4,5])
    assert contains_cycle?(u_cycles, [4,6])
    assert_equal 16, u_cycles.size
  end

end
