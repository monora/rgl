# Rakefile for RGL        -*- ruby -*-

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end
require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'

# Determine the current version of the software

if `ruby -Ilib -rrgl/base -e'puts RGL_VERSION'` =~ /\S+$/
  PKG_VERSION = $&
else
  PKG_VERSION = "0.0.0"
end

SUMMARY = "Ruby Graph Library"
SOURCES = FileList['lib/**/*.rb']
RDOC_DIR = './rgl'

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :test

# Define a test task.

Rake::TestTask.new { |t|
  t.libs << "tests"
  t.pattern = 'tests/Test*.rb'
  t.verbose = true
}

task :test

# Define a test that will run all the test targets.
desc "Run all test targets"
task :testall => [:test ]

# Install rgl using the standard install.rb script.

desc "Install the application"
task :install do
  ruby "install.rb"
end

# CVS Tasks ----------------------------------------------------------

desc "Tag all the CVS files with the latest release number (TAG=x)"
task :tag do
  rel = "REL_" + PKG_VERSION.gsub(/\./, '_')
  rel << ENV['TAG'] if ENV['TAG']
  puts rel
  sh %{cvs commit -m 'pre-tag commit'}
  sh %{cvs tag #{rel}}
end

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = RDOC_DIR
#  rdoc.template = 'kilmer'
#  rdoc.template = 'css2'
  rdoc.title    = SUMMARY
  rdoc.options << '--line-numbers' << '--inline-source' <<
     '--main' << 'README'
  rdoc.rdoc_files.include(SOURCES, 'README', 'examples/examples.rb')
}

# ====================================================================
# Create a task that will package the rgl software into distributable
# tar, zip and gem files.

PKG_FILES = FileList[
  'install.rb',
  '[A-Z]*',
  'tests/**/*.rb',
  'examples/**/*'
] + SOURCES

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    
    #### Basic information.

    s.name = 'rgl'
    s.version = PKG_VERSION
    s.summary = SUMMARY

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
    EOF

    #### Dependencies and requirements.

    s.add_dependency('stream', '>= 0.5')
    s.requirements << "Stream library, v0.5 or later"

    #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)
    s.files = PKG_FILES.to_a

    #### Load-time details: library and application (you will need one or both).

    s.require_path = 'lib'                         # Use these for libraries.
    s.autorequire = 'rgl'

    #### Documentation and testing.

    s.has_rdoc = true
    s.extra_rdoc_files = ['README']
    s.rdoc_options <<
      '--title' <<  'RGL - Ruby Graph Library' <<
      '--main' << 'README' <<
      '--line-numbers'

    #### Author and project details.
    s.author = "Horst Duchene"
    s.email = "hd.at.clr@hduchene.de"
    s.homepage = "rgl.rubyforge.org"
    s.rubyforge_project = "rgl"
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    #pkg.need_zip = true
    pkg.need_tar = true
  end
end

# TAGS ---------------------------------------------------------------

file 'tags' => SOURCES do
  print "Running ctags..."
  sh %{ctags #{SOURCES.join(' ')}}             # vi tags
  puts "done."
end

file 'TAGS' => SOURCES do
  sh %{ctags -e #{SOURCES.join(' ')}}          # emacs TAGS
end

# Misc tasks =========================================================

def count_lines(filename)
  lines = 0
  codelines = 0
  open(filename) { |f|
    f.each do |line|
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  }
  [lines, codelines]
end

def show_line(msg, lines, loc)
  printf "%6s %6s   %s\n", lines.to_s, loc.to_s, msg
end

desc "Count lines in the main files"
task :lines do
  total_lines = 0
  total_code = 0
  show_line("File Name", "LINES", "LOC")
  SOURCES.each do |fn|
    lines, codelines = count_lines(fn)
    show_line(fn, lines, codelines)
    total_lines += lines
    total_code  += codelines
  end
  show_line("TOTAL", total_lines, total_code)
end

ARCHIVEDIR = '/mnt/flash'

task :archive => [:package] do
  cp FileList["pkg/*.tgz", "pkg/*.zip", "pkg/*.gem"], ARCHIVEDIR
end

desc "Copy rdoc html to rubyforge"
task :rdoc2rf => [:rdoc] do
  sh "scp -r #{RDOC_DIR} monora@rubyforge.org:/var/www/gforge-projects/rgl"
  sh "scp examples/*.jpg monora@rubyforge.org:/var/www/gforge-projects/rgl/examples"
end
