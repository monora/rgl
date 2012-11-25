# -*- ruby -*-

require 'rubygems'
require 'bundler/setup'

require 'rubygems/package_task'

require 'rake/testtask'
require 'rdoc/task'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/base' # require base module to get RGL_VERSION

SUMMARY = "Ruby Graph Library"
SOURCES = FileList['lib/**/*.rb']
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

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

begin
  require 'rcov/rcovtask'

  desc "Calculate code coverage with rcov"
  Rcov::RcovTask.new(:rcov) do |t|
    t.libs << 'test'
    t.pattern = 'test/*_test.rb'
    t.verbose = true
    t.rcov_opts += ['--exclude', 'test/,gems/']
  end
rescue LoadError
  nil # rdoc is available only on Ruby 1.8
end

# Git tagging

desc "Commit all changes as a new version commit. Tag the commit with v<version> tag"
task :tag do
  puts "Committing and tagging version #{RGL_VERSION}"
  `git commit -am 'Version #{RGL_VERSION}'`
  `git tag 'v#{RGL_VERSION}'`
end

# Create a task to build the RDOC documentation tree.

Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = RDOC_DIR
  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = SUMMARY
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  rdoc.rdoc_files.include(SOURCES, 'README.rdoc', 'ChangeLog', 'examples/examples.rb', 'rakelib/*.rake')
end

# Tasks for building and installing RGL gem.

Bundler::GemHelper.install_tasks

# TAGS ---------------------------------------------------------------

file 'tags' => SOURCES do
  print "Running ctags..."
  sh %{ctags #{SOURCES.join(' ')}}             # vi tags
  puts "done."
end

file 'TAGS' => SOURCES do
  sh %{etags #{SOURCES.join(' ')}}          # emacs TAGS
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
task :rdoc2rf => [:rdoc, :rcov] do
  cp_r 'coverage', RDOC_DIR
  examples = File.join(RDOC_DIR, 'examples')
  mkdir_p examples
  cp Dir.glob('examples/*.jpg'), examples
  sh "rsync -r --delete \"#{RDOC_DIR}\" \"#{REMOTE_RDOC_DIR}\""
end
