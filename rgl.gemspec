$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/version'

Gem::Specification.new do |s|
  s.name    = 'rgl'
  s.version = RGL::VERSION
  s.summary = "Ruby Graph Library"
  s.description = "RGL is a framework for graph data structures and algorithms"
  s.licenses = ['Ruby']
  s.required_ruby_version = '>= 3.1'

  s.metadata = {
    "homepage_uri"          => "https://github.com/monora/rgl",
    "source_code_uri"       => "https://github.com/monora/rgl",
    "changelog_uri"         => "https://github.com/monora/rgl/blob/master/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  #### Dependencies and requirements.

  s.add_dependency 'stream',     '~> 0.5.3'
  s.add_dependency 'pairing_heap', '>= 0.3', '< 4.0'
  s.add_dependency 'rexml', '~> 3.2', '>= 3.2.4'

  #### Which files are to be included in this gem?

  s.files = Dir[
      'lib/**/*.rb',
      'CHANGELOG.md',
      'examples/**/*',
      'Gemfile',
      'README.md',
      'Rakefile',
      'rakelib/*.rake',
      'test/**/*.rb',
  ]

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'

  #### Author and project details.

  s.authors           = [
    "Horst Duchene",
    "Kirill Lashuk"
  ]

  s.email             = "monora@gmail.com"
  s.homepage          = "https://github.com/monora/rgl"
end
