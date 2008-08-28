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
rgl_version =
if %x(ruby -Ilib -rrgl/base -e'puts RGL_VERSION') =~ /\S+$/
  $&
else
  "0.0.0"
end

SUMMARY = "Ruby Graph Library"
SOURCES = FileList['lib/**/*.rb']
CLOBBER.include('TAGS', 'coverage')
RDOC_DIR = './rgl'

# The location for published documents to be copied.
remote_user = ENV['REMOTE_USER'] || ''
remote_host = ENV['REMOTE_HOST'] || 'rubyforge.org'
remote_path = ENV['REMOTE_PATH'] || '/var/www/gforge-projects/rgl'
remote_path += '/' unless remote_path[-1, 1] == '/'
REMOTE_RDOC_DIR = remote_path
REMOTE_RDOC_DIR.insert(
  0,
  remote_user + (remote_user.empty? ? '' : '@') + remote_host + ':'
) unless remote_host.empty?

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

desc "Do code coverage with rcov"
task :rcov do
  begin 
    sh 'rcov -Ilib:tests --exclude "tests/.*[tT]est.*.rb,usr.local" tests/Test*rb'
  rescue Exception
    nil
  end
end

# Install rgl using the standard install.rb script.

desc "Install the library"
task :install do
  ruby "install.rb"
end

# CVS Tasks ----------------------------------------------------------

desc "Tag all the CVS files with the latest release number (TAG=x)"
task :tag do
  rel = "REL_" + rgl_version.gsub(/\./, '_')
  rel << ENV['TAG'] if ENV['TAG']
  puts rel
  sh %{cvs commit -m 'pre-tag commit'}
  sh %{cvs tag #{rel}}
end

desc "Accumulate changelog"
task :changelog do
  sh %{cvs2cl --tags --utc --prune --accum}
end

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = RDOC_DIR
  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = SUMMARY
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include(SOURCES, 'README', 'ChangeLog', 'examples/examples.rb', 'rakelib/*.rake')
}

# ====================================================================
# Create a task that will package the rgl software into distributable
# tar, zip and gem files.

PKG_FILES = FileList[
  'install.rb',
  '[A-Z]*',
  'tests/**/*.rb',
  'examples/**/*',
  'rakelib/*.rake'
] + SOURCES

if ! defined?(Gem)
  puts "Package Target requires RubyGems"
else
  spec = Gem::Specification.new do |s|
    
    s.name = 'rgl'
    s.version = rgl_version
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
     * Transitive Reduction
     * Graph Condensation
     * Search cycles (contributed by Shawn Garbett)
    EOF
    
    #### Dependencies and requirements.
    
    s.add_dependency('stream', '>= 0.5')
    s.add_dependency 'rake'
    s.requirements << "Stream library, v0.5 or later"
    
    #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)
    s.files = PKG_FILES.to_a
    
    #### Load-time details: library and application (you will need one or both).
    
    s.require_path = 'lib'                         # Use these for libraries.
    s.autorequire = 'rgl/base'
    
    #### Documentation and testing.
    
    s.has_rdoc = true
    s.extra_rdoc_files = ['README']
    s.rdoc_options <<
      '--title' <<  'RGL - Ruby Graph Library' <<
      '--main' << 'README' <<
      '--line-numbers'
    
    #### Author and project details.
    s.author = "Horst Duchene"
    s.email = "monora@gmail.com"
    s.homepage = "http://rgl.rubyforge.org"
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

desc "Copy rdoc html to rubyforge"
task :rdoc2rf => [:rdoc, :rcov, :changelog] do
  cp_r 'coverage', RDOC_DIR
  examples = File.join(RDOC_DIR, 'examples')
  mkdir_p examples
  cp Dir.glob('examples/*.jpg'), examples
  sh "rsync -r --delete \"#{RDOC_DIR}\" \"#{REMOTE_RDOC_DIR}\""
end
