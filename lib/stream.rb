# = Extended External Iterators (forward and backward)
#
# == Description
# 
# Module Stream defines an interface for external iterators. A stream can be seen as
# an iterator on a sequence of objects x1,...,xn. The state of the stream is uniquely
# determined by the following methods:
# 
# * at_beginning?
# * at_end?
# * current
# * peek
# 
# State changes are done with the following operations:
# 
# * set_to_begin
# * set_to_end
# * forward
# * backward
# 
# With the help of the method current_edge the state of a stream s can be exactly defined
# 
#  s.current_edge == [s.current, s.peek]
# 
# If s a stream on [x1,...,xn]. Consider the edges [xi,xi+1] i=1,...,n
# and [x0,x1] and [xn,xn+1] (x0 and xn are helper elements to define the
# boundary conditions). Then if s is non empty, the following conditions must be true:
# 
#  s.at_beginning? <=> s.current_edge == [x0,x1]
#  s.at_end? <=> s.current_edge == [xn,xn+1]
#  s.isEmpty? <=> s.at_beginning? && s.at_end? <=> s.current_edge == [x0,x1] <=> n = 0
#  s.set_to_end => s.at_end?
#  s.set_to_begin => s.at_beginning?
# 
# If 0 <= i < n and s.current_edge == [xi, xi+1] , then:
# 
#  [s.forward, s.current_edge] == [xi+1, [xi+1, xi+2]]
# 
# If 1 <= i < n and s.current_edge == [xi, xi+1] , then:
# 
#  [s.backward, s.current_edge] == [xi, [xi-1, xi]]
# 
# The result of peek is the same as of forward without changing state. The result of
# current is the same as of backward without changing state.
# 
# Module Stream includes Enumerable implementing #each in the obvious way.
# 
# Not every stream needs to implement #backward and #at_beginning? thus being not
# reversable. If they are reversable peek can easily be implemented using forward and
# backward, as is done in module Stream. If a stream is not reversable all
# derived streams provided by the stream module (filter, mapping, concatenation) can be
# used anyway. Explicit or implicit (via peek or current) uses of backward would throw a
# NotImplementedError.
# 
# Classes implementing the stream interface must implement the following methods:
# 
# * basic_forward
# * basic_backward
# 
# * at_end?
# * at_beginning?
# 
# The methods set_to_end and set_to_begin are by default implemented as:
# 
#  set_to_end   :  until at_end?; do basic_forward end
#  set_to_begin :  until at_beginning?; do basic_backward end
# 
# The methods forward and backward are by default implemented as:
# 
#  forward:	   raise EndOfStreamException if at_end?; basic_forward.
#  backward:   raise EndOfStreamException if at_beginning?; basic_backward
# 
# Thus subclasses must only implement *four* methods. Efficiency sometimes demands better implementations.
# 
# There are several concrete classes implementing the stream interface:
# 
# * Stream::EmptyStream (boring)
# * Stream::CollectionStream created by the method Array#create_stream
# * Stream::FilteredStream created by the method Stream#filtered
# * Stream::ReversedStream created by the method Stream#reverse
# * Stream::ConcatenatedStream created by the method Stream#concatenate
# * Stream::ImplicitStream using closures for the basic methods to implement
# 
# == See also
# 
# * Streams in Smalltalk: http://wiki.cs.uiuc.edu/PatternStories/FunWithStreams
# * Iterators in Python: http://www.amk.ca/python/2.2/index.html#SECTION000300000000000000000
# * Discussion in Rubygarden on Iterative development: http://www.rubygarden.org/article.php?sid=107
# 
# == Examples
# 
#   g = ('a'..'f').create_stream
#   h = (1..10).create_stream
#   i = (10..20).create_stream
# 
#   until g.at_end? || h.at_end? || i.at_end?
#     p [g.forward, h.forward, i.forward]
#   end
# 
#   def filestream fname
#     Stream::ImplicitStream.new { |s|
#       f = open(fname)
#       s.at_end_proc = proc {f.eof?}
#       s.forward_proc = proc {f.readline}
#       # Need not implement backward moving to use the framework
#     }
#   end
# 
#   (filestream("/etc/passwd") + ('a'..'f').create_stream + filestream("/etc/group")).each do |l|
#     puts l
#   end
# 
#   puts "\nTwo filtered collection streams concatenated and reversed:\n\n"
# 
#   def newstream; (1..6).create_stream; end
#   s = newstream.filtered { |x| x % 2 == 0 } + newstream.filtered { |x| x % 2 != 0 }
#   s = s.reverse
#   puts "Contents      : #{s.to_a.join ' '}"
#   puts "At end?       : #{s.at_end?}"
#   puts "At beginning? : #{s.at_beginning?}"
#   puts "2xBackwards   : #{s.backward} #{s.backward}"
#   puts "Forward       : #{s.forward}"
#   puts "Peek          : #{s.peek}"
#   puts "Current       : #{s.current}"
#   puts "set_to_begin    : Peek=#{s.set_to_begin;s.peek}"
# 
#   # an infinite stream (do not use set_to_end!)
#   def randomStream
#     Stream::ImplicitStream.new { |s|
#       s.set_to_begin_proc = proc {srand 1234}
#       s.at_end_proc = proc {false}
#       s.forward_proc = proc {rand}
#     }
#   end
#   s = randomStream.filtered { |x| x >= 0.5 }.collect { |x| sprintf("%5.2f ",x*100) }
#   puts "5 random numbers: #{(1..5).collect {|x| s.forward}}\n" # =>
# 
#     5 random numbers: 74.05 94.80 87.87 86.07 83.70
#
# == Other Stuff
# $Revision$
# $Date$
# 
# Author:: Horst Duchêne <horst@hduchene.de>
# License:: Copyright (c) 2001 Horst Duchene
#           Released under the same license as Ruby

STREAM_VERSION = "V0.4"

##
# Module Stream defines an interface for an external Iterator which
# can move forward and backwards. See stream.rb for more information.
#
# The functionality is similar to Smalltalk's ReadStream.

module Stream
  include Enumerable

  # This exception is raised when the Stream is requested to move past
  # the end or beginning.
  class EndOfStreamException < StandardError; end

  # Returns false if the next #forward will return an element.
  def at_end?; raise NotImplementedError; end

  # Returns false if the next #backward will return an element.
  def at_beginning?; raise NotImplementedError; end

  # Move forward one position. Returns the _target_ of current_edge.
  # Raises Stream::EndOfStreamException if at_end? is true.
  def forward
    raise EndOfStreamException if at_end?
    basic_forward
  end

  # Move backward one position. Returns the _source_ of current_edge. Raises
  # Stream::EndOfStreamException if at_beginning? is true.
  def backward
    raise EndOfStreamException if at_beginning?
    basic_backward
  end

  # Position the stream before its first element, i.e. the next #forward
  # will return the first element.
  def set_to_begin
    until at_beginning?; basic_backward; end
  end

  # Position the stream behind its last element, i.e. the next #backward
  # will return the last element.
  def set_to_end
    until at_end?; basic_forward; end
  end

  protected

  def basic_forward; raise NotImplementedError; end
  def basic_backward; raise NotImplementedError; end

  def basic_current; backward; forward; end
  def basic_peek; forward; backward; end

  public

  # Move forward until the boolean block is not false and returns the element
  # found. Returns nil if no object matches.
  #
  # This is similar to #detect, but starts the search from the
  # current position. #detect, which is inherited from Enumerable uses
  # #each, which implicitly calls #set_to_begin.
  def move_forward_until
	until at_end?
	  element = basic_forward
	  return element if yield(element)
	end
	nil
  end

  # Move backward until the boolean block is not false and returns the element
  # found. Returns nil if no object matches.
  def move_backward_until
	until at_beginning?
	  element = basic_backward
	  return element if yield(element)
	end
	nil
  end
  
  # Returns the element returned by the last call of #forward. If at_beginning? is
  # true self is returned.
  def current; at_beginning? ? self : basic_current; end

  # Returns the element returned by the last call of #backward. If at_end? is
  # true self is returned.
  def peek; at_end? ? self : basic_peek; end

  # Returns the array [#current,#peek].
  def current_edge; [current,peek]; end

  # Returns the first element of the stream. This is accomplished by calling
  # set_to_begin and #forward, which means a state change.
  def first; set_to_begin; forward; end

  # Returns the last element of the stream. This is accomplished by calling
  # set_to_begin and #backward, which means a state change.
  def last; set_to_end; backward; end

  # Returns true if the stream is empty which is equivalent to at_end? and
  # at_beginning? both being true.
  def empty?; at_end? and at_beginning?; end

  # Implements the standard iterator used by module Enumerable, by calling
  # set_to_begin and basic_forward until at_end? is true.
  def each
    set_to_begin
    until at_end?
      yield basic_forward
    end
  end
  
  # create_stream is used for each Enumerable to create a stream for it. A Stream as
  # an Enumerable returns itself.
  def create_stream; self end

  # A Stream::WrappedStream should return the wrapped stream unwrapped. If the
  # stream is not a wrapper around another stream it simply returns itself.
  def unwrapped; self; end

  # The abstract super class of all concrete Classes implementing the Stream
  # interface. Only used for including module Stream.
  class BasicStream
	include Stream
  end

  # A Singleton class for an empty stream. EmptyStream.instance is the sole instance
  # which answers true for both at_end? and at_beginning?
  class EmptyStream < BasicStream
	require 'singleton'
	include Singleton

	def at_end?; true; end
	def at_beginning?; true; end
  end

  # A CollectionStream can be used as an external iterator for each interger-indexed
  # collection. The state of the iterator is stored in instance variable @pos.
  #
  # A CollectionStream for an array is created by the method Array#create_stream.
  class CollectionStream < BasicStream
	attr_reader :pos

	# Creates a new CollectionStream for the indexable sequence _seq_.
	def initialize(seq)
	  @seq = seq
	  set_to_begin
	end

	def at_end?; @pos + 1 >= @seq.size; end
	def at_beginning?; @pos < 0; end

	# positioning

	#
	def set_to_begin; @pos = -1; end
	def set_to_end; @pos = @seq.size - 1; end

	def basic_forward; @pos += 1; @seq[@pos]; end
	def basic_backward; r = @seq[@pos]; @pos -= 1; r; end

	protected

	# basic_current and basic_peek can be implemented more efficiently than in
	# superclass 
	def basic_current; @seq[@pos]; end
	def basic_peek; @seq[@pos+1]; end

  end							# CollectionStream

  # A simple Iterator for iterating over a sequence of integers starting from
  # zero up to a given upper bound. Mainly used by Stream::FilteredStream. Could be
  # made private but if somebody needs it here it is. Is there a better name for it?
  #
  # The upper bound is stored in the instance variable @stop which can be incremented
  # dynamically by the method increment_stop.
  class IntervalStream < BasicStream
	attr_reader :pos

	# Create a new IntervalStream with upper bound _stop_. stop - 1 is the last
	# element. By default _stop_ is zero which means that the stream is empty.
	def initialize (stop=0)
	  @stop = stop - 1
	  set_to_begin
	end

	def at_beginning?; @pos < 0; end
	def at_end?; @pos == @stop; end

	def set_to_end; @pos = @stop; end
	def set_to_begin; @pos = -1; end

	# Increment the upper bound by incr.
	def increment_stop (incr=1); @stop += incr; end

	def basic_forward; @pos += 1; end
	def basic_backward;  @pos -= 1; @pos + 1; end
  end

  # Class WrappedStream is the abstract superclass for stream classes that wrap
  # another stream. The basic methods are simple delegated to the wrapped
  # stream. Thus creating a WrappedStream on a CollectionStream would yield an
  # equivalent stream:
  #
  #  arrayStream = [1,2,3].create_stream
  #
  #  arrayStream.to_a => [1,2,3]
  #  Stream::WrappedStream.new(arrayStream).to_a => [1,2,3]
  class WrappedStream < BasicStream
	attr_reader :wrapped_stream

	# Create a new WrappedStream wrapping the Stream _otherStream_.
	def initialize (otherStream)
	  @wrapped_stream = otherStream
	end

	def at_beginning?; @wrapped_stream.at_beginning?; end
	def at_end?; @wrapped_stream.at_end?; end

	def set_to_end; @wrapped_stream.set_to_end; end
	def set_to_begin; @wrapped_stream.set_to_begin; end

	# Returns the wrapped stream unwrapped.
	def unwrapped; @wrapped_stream.unwrapped; end

	public # but should be protected. Would like to have a friend concept here.
	def basic_forward; @wrapped_stream.basic_forward; end
	def basic_backward;  @wrapped_stream.basic_backward; end
  end

  ##
  # A FilteredStream selects all elements which satisfy a given booelan block of
  # another stream being wrapped.
  #
  # A FilteredStream is created by the method #filtered:
  #
  #  (1..6).create_stream.filtered { |x| x % 2 == 0 }.to_a ==> [2, 4, 6]
  class FilteredStream < WrappedStream

	# Create a new FilteredStream wrapping _otherStream_ and selecting all its
	# elements which satisfy the condition defined by the block_filter_.
	def initialize (otherStream, &filter)
	  super otherStream
	  @filter = filter
	  @positionHolder = IntervalStream.new
	  set_to_begin
	end

	def at_beginning?; @positionHolder.at_beginning?; end

	# at_end? has to look ahead if there is an element satisfing the filter
	def at_end?
	  @positionHolder.at_end? and
		begin
		  if @peek.nil?
			@peek = wrapped_stream.move_forward_until( &@filter ) or return true
			@positionHolder.increment_stop
		  end
		  false
		end
	end

	def basic_forward
	  result =
		if @peek.nil? 
		  wrapped_stream.move_forward_until(&@filter)
		else
		  # Do not move!!
		  @peek
		end
	  @peek = nil
	  @positionHolder.forward
	  result
	end

	def basic_backward
	  wrapped_stream.backward unless @peek.nil?
	  @peek = nil
	  @positionHolder.backward
	  wrapped_stream.move_backward_until(&@filter) or self
	end

	def set_to_end
	  # Not super which is a WrappedStream, but same behavior as in Stream
	  until at_end?; basic_forward; end
	end

	def set_to_begin
	  super
	  @peek = nil
	  @positionHolder.set_to_begin
	end

	# Returns the current position of the stream.
	def pos; @positionHolder.pos; end
  end							# FilteredStream

  ##
  # Each reversable stream (a stream that implements #backward and at_beginning?) can
  # be wrapped by a ReversedStream.
  #
  # A ReversedStream is created by the method #reverse:
  #
  #  (1..6).create_stream.reverse.to_a ==> [6, 5, 4, 3, 2, 1]
  class ReversedStream < WrappedStream

	# Create a reversing wrapper for the reversable stream _otherStream_. If
	# _otherStream_ does not support backward moving a NotImplementedError is signaled
	# on the first backward move.
	def initialize (otherStream)
	  super otherStream
	  set_to_begin
	end

	# Returns true if the wrapped stream is at_end?.
	def at_beginning?; wrapped_stream.at_end?; end
	# Returns true if the wrapped stream is at_beginning?.
	def at_end?; wrapped_stream.at_beginning?; end

	# Moves the wrapped stream one step backward.
	def basic_forward; wrapped_stream.basic_backward; end
	# Moves the wrapped stream one step forward.
	def basic_backward; wrapped_stream.basic_forward; end

	# Sets the wrapped stream to the beginning.
	def set_to_end; wrapped_stream.set_to_begin; end
	# Sets the wrapped stream to the end.
	def set_to_begin; wrapped_stream.set_to_end; end  
  end

  ##
  # The analog to Enumerable#collect for a stream is a MappedStream wrapping another
  # stream. A MappedStream is created by the method #collect, thus modifying
  # the behavior mixed in by Enumerable:
  #
  #  (1..5).create_stream.collect {|x| x**2}.type ==> Stream::MappedStream
  #  (1..5).collect {|x| x**2} ==> [1, 4, 9, 16, 25]
  #  (1..5).create_stream.collect {|x| x**2}.to_a ==> [1, 4, 9, 16, 25]
  class MappedStream < WrappedStream

	##
	# Creates a new MappedStream wrapping _otherStream_ which calls the block
	# _mapping_ on each move.
	def initialize (otherStream, &mapping)
	  super otherStream
	  @mapping = mapping
	end

	# Apply the stored closure for the next element in the wrapped stream and return
	# the result.
	def basic_forward; @mapping.call(super); end
	# Apply the stored closure for the previous element in the wrapped stream and return
	# the result.
	def basic_backward; @mapping.call(super); end
  end

  ##
  # Given a stream of streams. Than a ConcatenatedStream is obtained by concatenating
  # these in the given order. A ConcatenatedStream is created by the methods
  # Stream#concatenate or Stream#concatenate_collected send to a stream of streams or
  # by the method + which concatenats two streams:
  #
  #  ((1..3).create_stream + [4,5].create_stream).to_a ==> [1, 2, 3, 4, 5]
  class ConcatenatedStream < WrappedStream
	alias :streamOfStreams :wrapped_stream
	private :streamOfStreams

	# Creates a new ConcatenatedStream wrapping the stream of streams _streamOfStreams_.
	def initialize (streamOfStreams)
	  super
	  set_to_begin
	end

	# If the current stream is at end, than at_end? has to look ahead to find a non
	# empty in the stream of streams, which than gets the current stream.
	def at_end?
 	  @currentStream.at_end? and
		begin
		  until streamOfStreams.at_end?
			dir, @dirOfLastMove = @dirOfLastMove, :forward
			s = streamOfStreams.basic_forward
			# if last move was backwards, then @currentStream is
			# equivalent to s. Move to next stream.
			next if dir == :backward
			s.set_to_begin
			if s.at_end?			# empty stream?
			  next				# skip it
			else
			  @currentStream = s
			  return false		# found non empty stream
			end
		  end
		  reachedBoundary		# sets @dirOfLastMove and @currentStream
		end
  	end

	# Same as at_end? the other way round.
  	def at_beginning?
	  # same algorithm as at_end? the other way round. Could we do it
	  # with metaprogramming?
 	  @currentStream.at_beginning? and
		begin
		  until streamOfStreams.at_beginning?
			dir, @dirOfLastMove = @dirOfLastMove, :backward
			s = streamOfStreams.basic_backward
			next if dir == :forward
			s.set_to_end
			if s.at_beginning?
			  next
			else
			  @currentStream = s
			  return false
			end
		  end
		  reachedBoundary
		end
  	end
  	
	def set_to_begin; super; reachedBoundary end
	def set_to_end; super; reachedBoundary end

	# Returns the next element of @currentStream. at_end? ensured that there is one.
	def basic_forward; @currentStream.basic_forward end
	# Returns the previous element of @currentStream. at_beginning? ensured that
	# there is one. 
	def basic_backward; @currentStream.basic_backward end

	private
	
	def reachedBoundary
	  @currentStream = EmptyStream.instance
	  @dirOfLastMove = :none	# not :forward or :backward
	  true
	end
	# Uff, this was the hardest stream to implement.
  end							# ConcatenatedStream

  # An ImplicitStream is an easy way to create a stream on the fly without defining a
  # subclass of BasicStream. The basic methods required for a stream are defined with
  # blocks: 
  #
  #  s = Stream::ImplicitStream.new { |s|
  #		x = 0
  #		s.at_end_proc = proc {x == 5}
  #		s.forward_proc = proc {x += 1 }
  #	 }
  #
  #  s.to_a ==> [1, 2, 3, 4, 5]
  #
  # Note that this stream is only partially defined since backward_proc and
  # at_beginning_proc are not defined. It may as well be useful if only moving
  # forward is required by the code fragment.
  #
  # ImplicitStreams can be based on other streams using the method modify
  # which is for example used in the methods for creating stream wrappers which
  # remove the first or last element of an existing stream (see remove_first
  # and remove_last).
  class ImplicitStream < BasicStream
	attr_writer :at_beginning_proc, :at_end_proc, :forward_proc, :backward_proc, :set_to_begin_proc, :set_to_end_proc
	attr_reader :wrapped_stream

	# Create a new ImplicitStream which might wrap an existing stream
	# _otherStream_. If _otherStream_ is supplied the blocks for the basic stream
	# methods are initialized with closures that delegate all operations to the
	# wrapped stream.
	#
	# If a block is given to new, than it is called with the new ImplicitStream
	# stream as parameter letting the client overwriting the default blocks.
	def initialize (otherStream=nil)
	  if otherStream
		@wrapped_stream = otherStream
		@at_beginning_proc = proc {otherStream.at_beginning?}
		@at_end_proc = proc {otherStream.at_end?}
		@forward_proc = proc {otherStream.basic_forward}
		@backward_proc = proc {otherStream.basic_backward}
		@set_to_end_proc = proc {otherStream.set_to_end}
		@set_to_begin_proc = proc {otherStream.set_to_begin}
	  end
	  yield self if block_given? # let client overwrite defaults

	  @at_beginning_proc = proc {true} unless @at_beginning_proc
	  @at_end_proc = proc {true} unless @at_end_proc
	end

	# Returns the value of @at_beginning_proc.
	def at_beginning?; @at_beginning_proc.call; end
	# Returns the value of @at_end_proc.
	def at_end?; @at_end_proc.call; end
	
	# Returns the value of @forward_proc.
	def basic_forward; @forward_proc.call; end
	# Returns the value of @backward_proc_proc.
	def basic_backward; @backward_proc.call; end

	# Calls set_to_end_proc or super if set_to_end_proc is undefined.
	def set_to_end
	  @set_to_end_proc ? @set_to_end_proc.call : super
	end

	# Calls set_to_begin_proc or super if set_to_begin_proc is undefined.
	def set_to_begin
	  @set_to_begin_proc ? @set_to_begin_proc.call : super
	end
  end							# ImplicitStream

  # Stream creation functions

  ##
  # Return a Stream::FilteredStream which iterates over all my elements
  # satisfying the condition specified  by the block.
  def filtered (&block); FilteredStream.new(self,&block); end

  # Create a Stream::ReversedStream wrapper on self.
  def reverse; ReversedStream.new self; end
  
  # Create a Stream::MappedStream wrapper on self. Instead of returning the stream
  # element on each move, the value of calling _mapping_ is returned instead. See
  # Stream::MappedStream for examples.
  def collect (&mapping); MappedStream.new(self, &mapping); end

  # Create a Stream::ConcatenatedStream on self, which must be a stream of streams.
  def concatenate; ConcatenatedStream.new self; end

  # Create a Stream::ConcatenatedStream, concatenated from streams build with the
  # block for each element of self:
  # 
  #  s = [1, 2, 3].create_stream.concatenate_collected { |i|
  #    [i,-i].create_stream
  #  }.
  #  s.to_a ==> [1, -1, 2, -2, 3, -3]
  def concatenate_collected (&mapping); self.collect(&mapping).concatenate; end

  # Create a Stream::ConcatenatedStream by concatenatating the receiver and _otherStream_
  #
  #  (%w(a b c).create_stream + [4,5].create_stream).to_a ==> ["a", "b", "c", 4, 5]
  def + (otherStream)
	[self, otherStream].create_stream.concatenate
  end

  # Create a Stream::ImplicitStream which wraps the receiver stream by modifying one
  # or more basic methods of the receiver. As an example the method remove_first uses
  # #modify to create an ImplicitStream which filters the first element away.
  def modify (&block); ImplicitStream.new(self, &block); end

  # Returns a Stream::ImplicitStream wrapping a Stream::FilteredStream, which
  # eliminates the first element of the receiver.
  #
  #  (1..3).create_stream.remove_first.to_a ==> [2,3]
  def remove_first
	i = 0
	filter = self.filtered { | element | i += 1; i > 1 }
	filter.modify { |s|
	  s.set_to_begin_proc = proc {filter.set_to_begin; i = 0}
	}
  end

  # Returns a Stream which eliminates the first element of the receiver.
  #
  #  (1..3).create_stream.remove_last.to_a ==> [1,2]
  #
  # <em>Take a look at the source. The implementation is inefficient but elegant.</em>
  def remove_last
	self.reverse.remove_first.reverse	# I like this one
  end
end

# extensions

# The extension on Array could be done for all Objects supporting []
# and size.
class Array
  # Creates a new Stream::CollectionStream on self.
  def create_stream
    Stream::CollectionStream.new self
  end
end

module Enumerable
  # If not an array the enumerable is converted to an array and then
  # to a stream using a Stream::CollectionStream.
  def create_stream
    to_a.create_stream
  end
end
