#! /usr/bin/env ruby

require 'getoptlong'
require 'rbconfig'
require 'ftools'
require 'find'

SRC_BASE = 'lib'
SRC = 'rgl'


INSTDIR = File.join Config::CONFIG['sitedir']
DESTDIR = File.join INSTDIR, SRC

opts = GetoptLong.new( [ "--uninstall",	"-u",		GetoptLong::NO_ARGUMENT ] )

def install
  begin
    File.makedirs( DESTDIR )
    pwd = Dir.pwd
    Dir.chdir(SRC_BASE)
	Dir['*.rb'].each do |file|
      dst = File.join( INSTDIR, file )
      File.install(file, dst, 0644, true)
    end
    Find.find(SRC) do |file|
      dst = File.join( INSTDIR, file )
      File.install(file, dst, 0644, true) if file =~ /.rb$/
    end
    Dir.chdir(pwd)
  rescue
    puts $!
  end
end

def uninstall
  begin
    puts "Deleting:"
    Find.find(DESTDIR) { |file| File.rm_f file,true }
    Dir.delete DESTDIR
  rescue
  end
end

if (opt = opts.get) and opt[0] =~ /^-?-u/
  uninstall
else
  install
end
