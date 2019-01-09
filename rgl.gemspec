$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/base'

Gem::Specification.new do |s|
  s.name    = 'rgl'
  s.version = RGL_VERSION
  s.summary = "Ruby Graph Library"
  s.description = "RGL is a framework for graph data structures and algorithms"

  #### Dependencies and requirements.

  s.add_dependency 'stream',     '~> 0.5.2'
  s.add_dependency 'lazy_priority_queue', '~> 0.1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'test-unit'

  #### Which files are to be included in this gem?

  s.files = Dir[
      'lib/**/*.rb',
      'ChangeLog',
      'examples/**/*',
      'Gemfile',
      'README.md',
      'Rakefile',
      'rakelib/*.rake',
      'test/**/*.rb',
  ]

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'
  s.autorequire  = 'rgl/base'

  #### Documentation and testing.

  s.extra_rdoc_files = ['README.md']
  s.rdoc_options += [
      '--title', 'RGL - Ruby Graph Library',
      '--main', 'README.md',
      '--line-numbers'
  ]

  #### Author and project details.

  s.authors           = [
    "Horst Duchene",
    "Kirill Lashuk"
  ]

  s.email             = "monora@gmail.com"
  s.homepage          = "https://github.com/monora/rgl"
end
