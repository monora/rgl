# Some graph examples

require 'rgl/adjacency'
require 'rgl/implicit'

# partite 8, 5
def partite(n,m)
  result = RGL::DirectedAdjacencyGraph.new
  1.upto(n) { |i|
	1.upto(m) { |j|
		result.add_edge('a'+i.to_s,'b'+j.to_s)
	}
  }
  result
end

# modulo(30, 5).dotty
def modulo (n, m)
  result = RGL::AdjacencyGraph.new
  1.upto(n) { |x|
    1.upto(n) {|y|
      result.add_edge x,y if x != y && x%m == y%m }
  }
  result
end

# Cyclic graph with _n_ vertices
def cycle (n)
  RGL::ImplicitGraph.new { |g|
	g.vertex_iterator { |b| 0.upto(n-1,&b) }
	g.adjacent_iterator { |x, b| b.call((x+1)%n) }
	g.directed = true
  }
end

# Complete Graph with _n_ vertices
def complete (n)
  set = n.integer? ? (1..n) : n
  RGL::ImplicitGraph.new { |g|
	g.vertex_iterator { |b| set.each(&b) }
	g.adjacent_iterator { |x, b|
	  set.each { |y| b.call(y) unless x == y }
	}
  }
end

# Directed graph of ruby modules. Edges are defined by the method _ancestors_
def module_graph
  RGL::ImplicitGraph.new { |g|
	g.vertex_iterator { |b|
	  ObjectSpace.each_object(Module, &b) 
	}
	g.adjacent_iterator { |x, b|
	  x.ancestors.each { |y|
		b.call(y) unless x == y || y == Kernel || y == Object
	  }
	}
	g.directed = true
  }
end

# Shows graph of divisors of all integers from 2 to _n_.
def divisors(n)
  RGL::ImplicitGraph.new { |g|
	g.vertex_iterator { |b| 2.upto(n,&b) }
	g.adjacent_iterator { |x, b|
		n.downto(x+1) { |y| b.call(y) if y % x == 0 }
	}
	g.directed = true
  }
end

def bfs_example(g=cycle(5), start=g.detect {|x| true})
  require 'rgl/traversal'

  g.bfs_search_tree_from(start)
end

# Would like to have GraphXML here
def graph_from_dotfile (file)
  g = RGL::AdjacencyGraph.new
  pattern = /\s*([^\"]+)[\"\s]*--[\"\s]*([^\"\[\;]+)/ # ugly but works
  IO.foreach(file) { |line|
	case line
	when /^digraph/
	  g = RGL::DirectedAdjacencyGraph.new
	  pattern = /\s*([^\"]+)[\"\s]*->[\"\s]*([^\"\[\;]+)/
	when pattern
	  g.add_edge $1,$2
	else
	  nil
	end
  }
  g
end

# ruby -Ilib -r examples/examples.rb -rrgl/dot -e'bfs_example(module_graph,RGL::AdjacencyGraph).dotty'

if $0 == __FILE__
  require 'rgl/dot'

  dg = RGL::DirectedAdjacencyGraph[1,2 ,2,3 ,2,4, 4,5, 6,4, 1,6]
  dg.dotty
  dg.write_to_graphic_file
  bfs_example(dg,1).dotty
  bfs_example(graph_from_dotfile('dot/unix.dot'), 'Interdata').dotty({'label'=>'Interdata Nachfolger', 'fontsize' => 12})

  g = module_graph
  tree = bfs_example(module_graph,RGL::AdjacencyGraph)
  g = g.vertices_filtered_by {|v| tree.has_vertex? v}
  g.write_to_graphic_file
  g.dotty
end

