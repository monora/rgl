# -*- ruby -*-

begin
  require 'rgl/dot'
  require 'rgl/implicit'
rescue Exception
  nil
end

# Example usage:
#
#  rake -R/home/hd/src/rgl/rakelib -f /usr/lib/ruby/gems/1.8/gems/rails-1.0.0/Rakefile dep_graph
desc "Generate dependency graph of rake tasks"
task :dep_graph do |task|
  this_task = task.name
  dep = RGL::ImplicitGraph.new { |g|
    # vertices of the graph are all defined tasks without this task
	g.vertex_iterator do |b|
      Rake::Task.tasks.each do |t|
        b.call(t) unless t.name == this_task
      end
    end
    # neighbors of task t are its prerequisites
    g.adjacent_iterator { |t, b| t.prerequisites.each(&b) }
    g.directed = true
  }

  dep.write_to_graphic_file('png', this_task)
  puts "Wrote dependency graph to #{this_task}.png."
end
