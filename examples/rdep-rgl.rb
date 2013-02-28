#
# Simple extensions of Hal Fultons tool to show dependencies between ruby
# source files (see http://hypermetrics.com/rubyhacker/code/rdep/). The basic
# extensions can be found at the end of the function find_files.
#
# Source: [http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/rgl/rgl/examples/rdep-rgl.rb]
#
# Additionaly rdep-rgl.rb generates a graphics file named
# File.basename(ARGV[0]) + ".png".
#
# Requires RGL (http://rgl.sourceforge.net) and Graphviz
# (www.research.att.com/sw/tools/graphviz/download.html).
#
#  ruby rdep-rgl.rb j:/ruby/lib/ruby/site_ruby/1.6/rdoc/rdoc.rb
#
# produces the following graph: link:rdoc.rb.png
#
require 'rgl/adjacency'
require 'rgl/dot'

=begin

rdep - The Ruby Dependency Tool
Version 1.4

Hal E. Fulton
2 November 2002
Ruby's license

Purpose

  Determine the library files on which a specified Ruby file is dependent
  (and their location and availability).

Usage notes

  Usage: ruby rdep.rb sourcefile

  The sourcefile may or may not have a .rb extension.

  The directories in the $: array (which includes the RUBYLIB environment
  variable) are searched first. File extensions are currently searched for
  in this order: no extension, .rb, .o, .so, .dll (this may not be correct).

  If there are no detected dependencies, the program will give the
  message, "No dependencies found."

  If the program finds [auto]load and require statements that it can
  understand, it searches for the specified files. Any recognized Ruby
  source files (*.rb) are processed recursively in the same way. No attempt
  is made to open the files that appear to be binary.

  The program will print up to four lists (any or all may be omitted):
    1. A list of files it found by going through RUBYLIB.;
    2. A list of files found under the searchroot (or under '.');
    3. A list of directories under searchroot which should perhaps be
       added to RUBYLIB; and
    4. A list of files (without extensions) which could not be found.

  If there were unparseable [auto]load or require statements, a warning
  will be issued.

  Between lists 3 and 4, the program will give an opinion about the overall
  situation. The worst case is that files were not found; the uncertain
  case is when there were unparseable statements; and the best case is
  when all files could be found (lists 1 and 2).

Exit codes

  0 - Usage or successful execution
  1 - Nonexistent sourcefile specified
  2 - Improper sourcefile (pipe, special file, ...)
  3 - Some kind of problem reading a file

Limitations

  Requires Ruby 1.6.0 or higher
  No recursion on binaries
  Can't look at dynamically built names
  Can't detect "tested" requires (e.g.: flag = require "foo.rb")
  [auto]load/require can be preceded only by whitespace on the line
  Only recognizes simple strings ("file" or 'file')
  Does not recognized named constants (e.g.: require MyFile)
  Assumes every directory entry is either a file or subdirectory
  Does not handle the Windows variable RUBYLIB_PREFIX
  May be SLOW if a directory structure is deep (especially
    on Windows with 1.6.x)

Known bugs:

  Logic may be incorrect in terms of search order, file extensions, etc.
  Injected a bug in 1.3: In rare cases will recurse until stack overflow

Revision history

  Version 1.0 - 13 October 2000  - Initial release
  Version 1.1 - 10 July 2001     - Bug fixes
  Version 1.2 - 15 August 2002   - Works correctly on Win98
  Version 1.3 - 21 October 2002  - Removed globals; removed search root;
                                   added $: instead of RUBYLIB; etc.
  Version 1.4 -  2 November 2002 - Fixed autoload recursion bug

To-do list

  Possibly change extension search order?
  Possibly add extensions to list?
  Are explicit extensions allowed other than .rb?
  Is a null extension really legal?
  Additional tests/safeguards? (file permissions, non-empty files,...)
  Change inconsistent expansion of tilde, dot, etc.?
  Make it smarter somehow??

=end

#
# File.doc_skip - iterator to skip embedded docs in Ruby input file
#

class File

  def doc_skip
    loop do
      str = gets
      break if not str
      if str =~ /^=begin([ \t]|$)/
        loop do
          str = gets
          break if not str
          break if str =~ /^=end([ \t]|$)/
        end
      else
        yield str
      end
    end
  end

end

class Dependency
  attr_reader :graph

  #
  # unquote - Find the value of a string. Called from scan.
  #

  def unquote(str)
    # Still more kludgy code.
    return nil if str == nil
    if [?', ?"].include? str[0] # ' Unconfuse gvim
      str = str[1..-2]
    else
      ""
    end
  end

  #
  # scan - Scans a line and returns the filename from a load or require
  #        statement. Returns null string if there was a parsing problem.
  #        Returns nil if this is not a load or require.
  #

  def scan(line)
    line.strip!
    if line =~ /^load/ or line =~ /^auto/ or line =~ /^require/
      @has_dep = true # At least one dependency found.
                      # Kludge!!
      junk = %w[ require load autoload ( ) , ] + [""]
      temp = line.split(/[ \t\(\),]/) - junk
      if temp[2] and temp[2][0].chr =~ /[#;]/ # Comments, semi...
        temp = temp[0..1]
      end
      if temp[-1] =~ /\#\{/ # #{} means trouble
        str = ""
      else
        str = unquote(temp[-1]) # May return nil.
      end
      str
    else
      nil
    end
  end

#
# find_files - The heart of the program. Search for files using $:
#

  def find_files(source)
    # loadable - This file or some variant can be found in one of the
    #            directories in $:
    loadable = false

    files = [] # Save a list of load/require files.
    found = [] # Save a list of files found (.rb only for now)

    # Open the file, strip embedded docs, and look for load/require statements.

    begin
      File.open(source).doc_skip { |line| files << scan(line) }
    rescue => err
      puts "Problem processing file #{source}: #{err}"
      caller.each { |x| puts "  #{x}" }
      exit 3
    end

    # If no dependencies, don't bother searching!
    if !@has_dep
      puts "No dependencies found."
      exit 0
    end

    files.compact!
    catch(:skip) do
      for file in files

        if file == "" # Warning
          @warnfiles << source
          next
        end

        throw :skip if (@inpath.include? file) || (@cantfind.include? file)

        if file =~ /\.rb$/ # Don't add suffix to *.rb
          suffixes = [""] # Hmm... .rbw?? Probably not needed.
        else
          suffixes = @suffixes # Use any suffix (extension)
        end

        # Look through search path (@search_path)

        for dir in @search_path

          for suf in suffixes
            filename = dir + file + suf
            loadable = test ?e, filename
            break if loadable
          end

          if loadable
            @inpath << filename # Files we found in RUBYLIB
                                # Add to 'found' if it's a source file (so we can recurse)
            found << filename if filename =~ /\.rb$/
            break
          end

        end

        @cantfind << file if !loadable
      end
    end

    found.uniq!
    found.compact!

    @graph.add_vertex(source)

    list = found
    found.each { |x|
      @graph.add_edge(source, x)
      list += find_files(x)
    }

    list
  end

  #
  # print_list - Print a header message followed by a list of files
  #              or directories.
  #

  def print_list(header, list)
    return if list.empty?
    puts header + "\n\n" # Extra newlines
    list.each { |x| puts "  #{x}" }
    puts "\n" # Extra newline
  end

  SEP    = File::Separator
  DIRSEP = SEP == "/" ? ":" : ";"

  def execute
    @has_dep      = false
    @warnfiles    = []
    @newdirs      = []
    @inpath       = []
    @cantfind     = []
    @suffixes     = [""] + %w[ .rb .o .so .dll ]
    @rdirs        = []
    @global_found = []
    @graph        = RGL::DirectedAdjacencyGraph.new

    # No parameters? Usage message

    if not ARGV[0]
      puts "Usage: ruby rdep.rb sourcefile [searchroot]"
      exit 0
    end

    # Does sourcefile exist?

    if !test ?e, ARGV[0]
      puts "#{ARGV[0]} does not exist."
      exit 1
    end

    # Is sourcefile a "real" file?

    if !test ?f, ARGV[0]
      puts "#{ARGV[0]} is not a regular file."
      exit 2
    end

    # Be sure to search under the dir where the
    # program lives...

    @proghome = File.dirname(File.expand_path(ARGV[0]))
    if @proghome != File.expand_path(".")
      $: << @proghome
    end

    # Get list of dirs in $:

    @search_path = $:
    @search_path.collect! { |x| x[-1] == SEP ? x : x + SEP }

    # All real work happens here -- big recursive find

    find_files(ARGV[0])

    @warnfiles.uniq!
    @cantfind.uniq!
    @newdirs.uniq!
    @inpath.map! { |x| File.expand_path(x) }
    @inpath.uniq!

    #
    # Now, what are all the results? Report to user.
    #

    if @inpath[0]
      print_list("Found in search path:", @inpath)
      if !@cantfind.empty? && @warnfiles.empty?
        puts "This will probably be sufficient.\n"
      end
    end

    # Did we use any dirs under the "home"?

    homedirs = @inpath.find_all { |x| x =~ Regexp.new("^"+@proghome) }
    if homedirs[0] # not empty
      homedirs.map! { |x| File.dirname(x) }.uniq!
      puts "Consider adding these directories to RUBYPATH:\n\n"
      homedirs.each { |x| puts "  #{x}" }
      puts
      if @warnfiles[0] and homedirs == [] # There are unparseable statements.
        puts "This will probably NOT be sufficient. See below.\n\n"
      end
    end

    # What's our opinion?

    if @cantfind[0] # There are unknown files.
      puts "This will probably NOT be sufficient. See below.\n\n"
    elsif @warnfiles[0] and homedirs == [] # There are unparseable statements.
      puts "Files may still be missing. See below.\n\n"
    else # We think everything is OK.
      puts "This will probably be sufficient."
    end

    # Report unknown files
    print_list("Not located anywhere:", @cantfind)

    # Print warning about load/require strings we couldn't understand
    print_list("Warning: Unparseable usages of 'load' or 'require' in:",
               @warnfiles)
  end

end

d = Dependency.new
d.execute
begin
  d.graph.write_to_graphic_file('png',
                                File.basename(ARGV[0]),
                                'label' => "Dependencies of #{ARGV[0]}")
rescue ArgumentError
  d.graph.write_to_graphic_file('png',
                                File.basename(ARGV[0]))
end


exit 0
