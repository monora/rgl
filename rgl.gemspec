$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/base'

Gem::Specification.new do |s|
  s.name    = 'rgl'
  s.version = RGL_VERSION
  s.summary = "Ruby Graph Library"

  s.description = <<-EOF
    RGL is a framework for graph data structures and algorithms.

    The design of the library is much influenced by the Boost Graph Library (BGL)
    which is written in C++ heavily using its template mechanism.

    RGL currently contains a core set of algorithm patterns:

     * Breadth First Search
     * Depth First Search

    The algorithm patterns by themselves do not compute any meaningful quantities
    over graphs, they are merely building blocks for constructing graph
    algorithms. The graph algorithms in RGL currently include:

     * Topological Sort
     * Connected Components
     * Strongly Connected Components
     * Transitive Closure
     * Transitive Reduction
     * Graph Condensation
     * Search cycles (contributed by Shawn Garbett)
  EOF

  #### Dependencies and requirements.

  s.add_dependency 'stream', '>= 0.5'
  s.add_dependency 'rake'

  #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)

  s.files = Dir[
      'lib/**/*.rb',
      'ChangeLog',
      'examples/**/*',
      'Gemfile',
      'README',
      'Rakefile',
      'rakelib/*.rake',
      'test/**/*.rb',
  ]

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'
  s.autorequire  = 'rgl/base'

  #### Documentation and testing.

  s.has_rdoc = true
  s.extra_rdoc_files = ['README']
  s.rdoc_options += [
      '--title', 'RGL - Ruby Graph Library',
      '--main', 'README',
      '--line-numbers'
  ]

  #### Author and project details.

  s.author            = "Horst Duchene"
  s.email             = "monora@gmail.com"
  s.homepage          = "http://rgl.rubyforge.org"
  s.rubyforge_project = "rgl"
end