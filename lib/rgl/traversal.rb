# traversal.rb
#
# This file defines the basic graph traversal algorithm for DFS and BFS search.
# They are implemented as an RGL::GraphIterator, which is a Stream of vertices
# of a given graph. The streams are not reversable.
#
# Beside being an iterator in the sense of the Stream mixin, RGL::BFSIterator
# and RGL::DFSIterator follow the BGL
# Visitor[http://www.boost.org/libs/graph/doc/visitor_concepts.html] Concepts
# in a slightly modified fashion (especially for the RGL::DFSIterator).

require 'rgl/base'
require 'rgl/graph_visitor'
require 'rgl/graph_iterator'

module RGL

  # A BFSIterator can be used to traverse a graph from a given start vertex in
  # breath first search order. Since the Iterator also mixins the GraphVisitor,
  # it provides all event points defined there.
  #
  # The vertices which are not yet visited are held in the queue @waiting.
  # During the traversal, vertices are *colored* using the colors :GRAY
  # (when waiting) and :BLACK when finished. All other vertices are :WHITE.
  #
  # For more doc see the BGL
  # BFS[http://www.boost.org/libs/graph/doc/BFSVisitor.html] Visitor Concept .
  #
  # See the implementation of bfs_search_tree_from for an example usage.
  #
  class BFSIterator

    include GraphIterator
    include GraphVisitor

    attr_accessor :start_vertex

    # Create a new BFSIterator on _graph_, starting at vertex _start_.
    #
    def initialize(graph, start = graph.detect { |x| true })
      super(graph)
      @start_vertex = start
      set_to_begin
    end

    # Returns true if the @color_map has only one entry (for the start vertex).
    #
    def at_beginning? # :nodoc:
      @color_map.size == 1
    end

    # Returns true if @waiting is empty.
    #
    def at_end?
      @waiting.empty?
    end

    # Reset the iterator to the initial state (i.e. at_beginning? == true).
    #
    def set_to_begin
      # Reset color_map
      @color_map = Hash.new(:WHITE)
      color_map[@start_vertex] = :GRAY
      @waiting = [@start_vertex]           # a queue
      handle_tree_edge(nil, @start_vertex) # discovers start vertex
      self
    end

    def basic_forward # :nodoc:
      u = next_vertex
      handle_examine_vertex(u)

      graph.each_adjacent(u) do |v|
        handle_examine_edge(u, v)
        if follow_edge?(u, v) # (u,v) is a tree edge
          handle_tree_edge(u, v) # also discovers v
          color_map[v] = :GRAY   # color of v was :WHITE
          @waiting.push(v)
        else # (u,v) is a non tree edge
          if color_map[v] == :GRAY
            handle_back_edge(u, v) # (u,v) has gray target
          else
            handle_forward_edge(u, v) # (u,v) has black target
          end
        end
      end

      color_map[u] = :BLACK
      handle_finish_vertex(u) # finish vertex
      u
    end

    protected

    def next_vertex # :nodoc:
      # waiting is a queue
      @waiting.shift
    end

  end # class BFSIterator

  module Graph

    # Returns a BFSIterator, starting at vertex _v_.

    def bfs_iterator(v = self.detect { |x| true })
      BFSIterator.new(self, v)
    end

    # Returns a DirectedAdjacencyGraph, which represents a BFS search tree
    # starting at _v_. This method uses the tree_edge_event of BFSIterator
    # to record all tree edges of the search tree in the result.

    def bfs_search_tree_from(v)
      require 'rgl/adjacency'
      bfs  = bfs_iterator(v)
      tree = DirectedAdjacencyGraph.new

      bfs.set_tree_edge_event_handler do |from, to|
        tree.add_edge(from, to)
      end

      bfs.set_to_end # does the search
      tree
    end

  end # module Graph

  # Iterator for a depth first search, starting at a given vertex. The only
  # difference from BFSIterator is that @waiting is a stack, instead of a queue.
  #
  # Note that this is different from DFSVisitor, which is used in the recursive
  # version for depth first search (see depth_first_search).
  #
  class DFSIterator < BFSIterator

    def next_vertex
      # waiting is a stack
      @waiting.pop
    end

  end # class DFSIterator

  # A DFSVisitor is needed by the depth_first_search and depth_first_visit
  # methods of a graph. Besides the eventpoint of GraphVisitor, it provides
  # an additional eventpoint start_vertex, which is called when a
  # depth_first_search starts a new subtree of the depth first forest that is
  # defined by the search.
  #
  # Note that the discover_vertex event defined in the BGL
  # DFSVisitor[http://www.boost.org/libs/graph/doc/DFSVisitor.html] is not
  # this is also defined in the common mixin GraphVisitor of DFSVisitor,
  # DFSIterator, and BFSIterator.
  #
  class DFSVisitor

    include GraphVisitor

    def_event_handler 'start_vertex'

  end # class DFSVisitor

  module Graph

    # Returns a DFSIterator staring at vertex _v_.

    def dfs_iterator(v = self.detect { |x| true })
      DFSIterator.new(self, v)
    end

    # Do a recursive DFS search on the whole graph. If a block is passed,
    # it is called on each _finish_vertex_ event. See
    # strongly_connected_components for an example usage.
    #
    # Note that this traversal does not garantee, that roots are at the top of
    # each spanning subtree induced by the DFS search on a directed graph (see
    # also the discussion in issue #20[https://github.com/monora/rgl/issues/20]).
    #
    def depth_first_search(vis = DFSVisitor.new(self), &b)
      each_vertex do |u|
        unless vis.finished_vertex?(u)
          vis.handle_start_vertex(u)
          depth_first_visit(u, vis, &b)
        end
      end
    end

    # Start a depth first search at vertex _u_. The block _b_ is called on
    # each finish_vertex event.
    #
    def depth_first_visit(u, vis = DFSVisitor.new(self), &b)
      vis.color_map[u] = :GRAY
      vis.handle_examine_vertex(u)

      each_adjacent(u) do |v|
        vis.handle_examine_edge(u, v)

        if vis.follow_edge?(u, v)          # (u,v) is a tree edge
          vis.handle_tree_edge(u, v)       # also discovers v
          vis.color_map[v] = :GRAY         # color of v was :WHITE
          depth_first_visit(v, vis, &b)
        else                               # (u,v) is a non tree edge
          if vis.color_map[v] == :GRAY
            vis.handle_back_edge(u, v)     # (u,v) has gray target
          else
            vis.handle_forward_edge(u, v)  # (u,v) is a cross or forward edge
          end
        end
      end

      vis.color_map[u] = :BLACK
      vis.handle_finish_vertex(u) # finish vertex
      b.call(u)
    end

  end # module Graph

end # module RGL
