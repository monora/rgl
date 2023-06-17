$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/version'

Gem::Specification.new do |s|
  s.name    = 'rgl'
  s.version = RGL::VERSION
  s.summary = "Ruby Graph Library"
  s.description = "RGL is a framework for graph data structures and algorithms"
  s.licenses = ['Ruby']

  #### Dependencies and requirements.

  s.add_dependency 'stream',     '~> 0.5.3'
  s.add_dependency 'pairing_heap', '~> 0.3'
  s.add_dependency 'rexml', '~> 3.2', '>= 3.2.4'

  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'yard', '~> 0.9'
  s.add_development_dependency 'test-unit', '~> 3.5'

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
