# topsort.rb

require 'rgl/traversal'

module RGL

  # Topological Sort Iterator
  #
  # The topological sort algorithm creates a linear ordering of the vertices
  # such that if edge (u,v) appears in the graph, then u comes before v in
  # the ordering. The graph must be a directed acyclic graph (DAG).
  #
  # The iterator can also be applied to undirected graph or to a DG graph
  # which contains a cycle.  In this case, the Iterator does not reach all
  # vertices.  The implementation of acyclic? uses this fact.

  class TopsortIterator

    include GraphIterator

    def initialize (g)
      super(g)
      set_to_begin
    end

    def set_to_begin				# :nodoc:
      @waiting   = Array.new
      @inDegrees = Hash.new(0)

      graph.each_vertex do |u|
        @inDegrees[u] = 0 unless @inDegrees.has_key?(u)
        graph.each_adjacent(u) do |v|
          @inDegrees[v] += 1
        end
      end

      @inDegrees.each_pair do |v, indegree|
        @waiting.push(v) if indegree.zero?
      end
    end

    def basic_forward				# :nodoc:
      u = @waiting.pop
      graph.each_adjacent(u) do |v|
        @inDegrees[v] -= 1
        @waiting.push(v) if @inDegrees[v].zero?
      end
      u
    end

    def at_beginning?; true;            end	# :nodoc: FIXME
    def at_end?;       @waiting.empty?; end	# :nodoc:

  end		# class TopsortIterator

  module Graph

    # Returns a TopsortIterator.

    def topsort_iterator
      TopsortIterator.new(self)
    end
        
    # Returns true if the graph contains no cycles.  This is only meaningful
    # for directed graphs.  Returns false for undirected graphs.

    def acyclic?
      topsort_iterator.length == num_vertices
    end

  end                           # module Graph
end                             # module RGL
