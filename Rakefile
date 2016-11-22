# -*- ruby -*-

require 'rubygems'
require 'bundler/setup'

require 'rubygems/package_task'

require 'rake/testtask'
require 'rake/clean'
require 'yard'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rgl/base' # require base module to get RGL_VERSION

SOURCES = FileList['lib/**/*.rb']

# The default task is run if rake is given no explicit arguments.
desc "Default Task"
task :default => :test

# Define a test task.

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

# Git tagging

desc "Commit all changes as a new version commit. Tag the commit with v<version> tag"
task :tag do
  puts "Committing and tagging version #{RGL_VERSION}"
  `git commit -am 'Version #{RGL_VERSION}'`
  `git tag 'v#{RGL_VERSION}'`
end

YARD::Rake::YardocTask.new

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

# simple rake task to output a changelog between two commits, tags ...
# output is formatted simply, commits are grouped under each author name
#
desc "generate changelog with nice clean output"
task :changelog, :since_c, :until_c do |t,args|
  since_c = args[:since_c] || `git tag | tail -1`.chomp
  until_c = args[:until_c]
  cmd=`git log --pretty='format:%ci::%an <%ae>::%s::%H' #{since_c}..#{until_c}`

  entries = Hash.new
  changelog_content = String.new

  cmd.split("\n").each do |entry|
    _, author, subject, hash = entry.chomp.split("::")
    entries[author] = Array.new unless entries[author]
    entries[author] << "#{subject} (#{hash[0..5]})" unless subject =~ /Merge/
  end

  # generate clean output
  entries.keys.each do |author|
    changelog_content += author + "\n"
    entries[author].reverse.each { |entry| changelog_content += " * #{entry}\n" }
  end

  puts changelog_content
end
