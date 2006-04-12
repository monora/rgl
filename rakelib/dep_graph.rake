require 'rgl/dot'
require 'rgl/implicit'

# Usage:
#
#  rake -R/home/hd/src/rgl/rakelib -f /usr/lib/ruby/gems/1.8/gems/rails-1.0.0/Rakefile dep_graph
desc "Show dependency graph of rake tasks"
task :dep_graph do

  dep = RGL::ImplicitGraph.new { |g|
	g.vertex_iterator { |b| Rake::Task.tasks.each (&b) }
	g.adjacent_iterator { |t, b| t.prerequisites.each (&b) }
	g.directed = true
  }

  dep.dotty
end

desc "Show gem dependency graph"
task :gem_graph do
  gem = Rake::Task.tasks.detect {|t| t.name == "package"}
  pp gem
end

