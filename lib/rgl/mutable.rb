require 'rgl/base'

module RGL
  # A MutableGraph can be changed via the addition or removal of edges and
  # vertices. 
  module MutableGraph
	include Graph

	# Add a new vertex _v_ to the graph. If the vertex is already in (using
	# eql?) the method does nothing.
	def add_vertex(v); raise NotImplementedError; end

	# Inserts the edge (u,v) into the graph.
	#
	# Note that for undirected graphs, (u,v) is the same edge as (v,u), so after
	# a call to the function add_edge(), this implies that edge (u,v) will
	# appear in the out-edges of u and (u,v) (or equivalently (v,u)) will appear
	# in the out-edges of 
	# v. Put another way, v will be adjacent to u and u will be adjacent to v. 
	def add_edge(u, v); raise NotImplementedError; end

	# Add all objects in _a_ to the vertex set.
	def add_vertices (*a)
	  a.each {|v| add_vertex v}
	end

	# Add all edges in the _edges_ array to the edge set. Element of the array
	# can be both two element arrays or instances of DirectedEdge or
	# UnDirectedEdge. 
	def add_edges (*edges)
	  edges.each {|edge| add_edge(edge[0],edge[1])}
	end

	# Remove u from the vertex set of the graph. All edges who's target is _v_
	# are also removed from the edge set of the graph.
	#
	# Postcondition: num_vertices is one less, _v_ no longer appears in the
	# vertex set of the graph and there no edge with source or target _v_.
	def remove_vertex(v); raise NotImplementedError; end

	# Remove the edge (u,v) from the graph. If the graph allows parallel edges
	# this remove all occurrences of (u,v).
	# 
	# Precondition: u and v are vertices in the graph.
	# Postcondition: (u,v) is no longer in the edge set for g.
	def remove_edge(u, v); raise NotImplementedError; end

	# Remove all vertices specified by the array a from the graph calling
	# remove_vertex.
	def remove_vertices (*a)
	  a.each {|v| remove_vertex v}
	end
  end
end
