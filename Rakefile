# -*- ruby -*-

require 'bundler/setup'
require 'rake/testtask'
require 'rake/clean'
require 'yard'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/version' # defines RGL::VERSION

SOURCES = FileList['lib/**/*.rb']

# The default task is run if rake is given no explicit arguments.
desc 'Default Task'
task :default => :test

# Define a test task.

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

# Test bfs_search_tree_from in isolation, to ensure that adjacency is not loaded by other tests.
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/traversal_bfs_require.rb'
  t.verbose = true
end

# Git tagging

desc 'Commit all changes as a new version commit. Tag the commit with v<version> tag'
task :tag do
  puts "Committing and tagging version #{RGL::VERSION}"
  `git commit -am 'Version #{RGL::VERSION}'`
  `git tag 'v#{RGL::VERSION}'`
end

YARD::Rake::YardocTask.new

# Tasks for building and installing RGL gem.

Bundler::GemHelper.install_tasks

# TAGS ---------------------------------------------------------------

file 'tags' => SOURCES do
  print 'Running ctags...'
  sh %(ctags #{SOURCES.join(' ')}) # vi tags
  puts 'done.'
end

file 'TAGS' => SOURCES do
  sh %(etags #{SOURCES.join(' ')}) # emacs TAGS
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

desc 'Count lines in the main files'
task :lines do
  total_lines = 0
  total_code = 0
  show_line('File Name', 'LINES', 'LOC')
  SOURCES.each do |fn|
    lines, codelines = count_lines(fn)
    show_line(fn, lines, codelines)
    total_lines += lines
    total_code += codelines
  end
  show_line('TOTAL', total_lines, total_code)
end
