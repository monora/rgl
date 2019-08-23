# frozen_string_literal: true

require 'rgl/traversal'

module RGL
  module Graph
    # Checks whether a path exists between _source_ and _target_ vertices
    # in the graph.
    #
    def path?(source, target)
      return false unless has_vertex?(source)

      bfs_iterator = bfs_iterator(source)
      bfs_iterator.include?(target)
    end
  end
end
