# = Class Set
# Author:  Jason Voegele (jason@jvoegele.com)
# Version: 1.0
# Date:    2001/09/30 16:34:37
# 
# = Synopsis
#     require 'set'
#     set1 = Set.new
#     set2 = Set.new([1, 2, 3, 5, 8, 13, 21, 34])
# 
#     1.upto(100) { |num|
#         set1.add(num)
#     }
# 
#     union = s1 | s2
#     intersection = s1 & s2
# 
#     puts("Union has #{union.length} elements:")
#     union.each { |element|
#         puts("\t#{element})
#     }
# 
#     puts("Intersection has #{intersection.length} elements")
#     intersection.each { |element|
#         puts("\t#{element})
#     }
# 
# = Description
# Class (({Set})) represents the mathematical concept of a set.  Sets are
# collections that may not contain any duplicate elements.  More formally, sets
# contain no pair of elements (({e1})) and (({e2})) such that (({e1.eql?(e2)})).
# 
# Elements stored in a set must provide appropriate semantics for the the
# (({hash})) and (({eql?})) methods.  In addition, if the elements in the set are
# to be sorted using the ((<sort>)) method without an associated "comparator"
# block, the elements must provide a meaningful (({<=>})) operator.

class Set
include Enumerable

=begin
= Class Methods
=end

=begin
--- Set.new(elements=[]) -> aSet
	Constructs a new set containing ((|elements|)), if any.  If provided,
	((|elements|)) must implement the ((|each|)) method appropriately.
=end
	def initialize(elements = [])
		@store = Hash.new
		elements.each do |element|
			add(element)
		end
	end

=begin
= Instance Methods
=end

=begin
--- Set#each
	Invokes the assocatied block for each element in the set.
=end
	def each
		for element in @store.keys
			yield element
		end
	end

=begin
--- Set#add(anObject) -> self
	Adds ((|anObject|)) to the set.  If ((|anObject|)) was already present
	in the set, overwrites it.  Returns the set.
--- Set#store(anObject) -> self
	Synonym for ((<Set#add>)).
=end
	def add(object)
		@store[object] = true
	end
	alias store add

=begin
--- Set#include?(anObject) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if ((|anObject|)) is in the set.
--- Set#member?(anObject) -> ((|true|)) or ((|false|))
	Synonym for ((<Set#include>)).
=end
	def include?(object)
		return @store[object] == true
	end
	alias member? include?

=begin
--- Set#length -> aNumber
	Returns the number of elements in the set.
--- Set#size -> aNumber
	Synonym for ((<Set#length>)).
=end
	def length
		@store.length
	end
	alias size length

=begin
--- Set#sort(&comparator) -> aSortedArray
	Returns a new array created by converting the set to an array and
	sorting	it. Comparisons for the sort will be done using the (({<=>}))
	operator or using an optional code block. The block implements a
	comparison between ((|a|)) and ((|b|)), returning -1, 0, or +1.

	set = Set.new([1, 2, 3, 4, 5]) # elements are not ordered in the set
	set.sort                    -> [1, 2, 3, 4, 5]
	set.sort { |a,b| b<=>a }    -> [5, 4, 3, 2, 1]
=end
	def sort(&comparator)
		@store.keys.sort!(&comparator)
	end

=begin
--- Set#clear -> self
	Removes all elements from the set.
=end
	def clear
		@store.clear
		return self
	end

=begin
--- Set#delete(anObject) -> anObject
	Deletes ((|anObject|)) from the set.  Returns ((|anObject|)) or
	((|nil|)) if ((|anObject|)) was not in the set.
=end
	def delete(object)
		@store.delete(object) ? object : nil
	end

=begin
--- Set#delete_if
	Deletes every element from the set for which the associated block
	evaluates to ((|true|)).

	set = Set.new([1,2,3,4,5,6,7,8,9,10])
	set.delete_if { |element| element > 5 } -> <1,2,3,4,5>
=end
	def delete_if
		return if not block_given?

		for element in @store.keys
			@store.delete(element) if yield element
		end
	end

=begin
--- Set#empty? -> ((|true|)) or ((|false|))
	Returns true if the set is the empty set.
=end
	def empty?
		@store.empty?
	end

=begin
--- Set#to_s -> aString
	Converts the set to a string containing a comma-separated list of
	elements enclosed between the < and > symbols.

	set = Set.new([1,2,3,4,5])
	set.to_s -> <1, 2, 3, 4, 5>
=end
	def to_s
		on_first = true
		result = "<"
		each do |element|
			if on_first
				on_first = false
			else
				result << ", "
			end
			result << element.to_s
		end
		result << ">"
		return result
	end

=begin
--- Set#to_a -> anArray
	Converts the set to an array containing the elements in the set.
=end
	def to_a
		@store.keys
	end

=begin
--- Set#union(anotherSet) -> aSet
	Returns a new set that is the union of this set and ((|anotherSet|)).
--- Set#|(anotherSet) -> aSet
	Synonym for ((<Set#union>)).
=end
	def |(another_set)
		result = self.class.new(another_set)
		each do |obj| result.add(obj) end
		return result
	end
	alias union |

=begin
--- Set#intersection(anotherSet) -> aSet
	Returns a new set that is the intersection of this set and
	((|anotherSet|)).
--- Set#&(anotherSet) -> aSet
	Synonym for ((<Set#intersection>)).
=end
	def &(another_set)
		result = self.class.new

		# Since we have to iterate through all of the elements of at least one
		# set, figure out which one is smaller and use that one
		smaller = bigger = nil
		if self.length < another_set.length
			smaller = self
			bigger = another_set
		else
			smaller = another_set
			bigger = self
		end
		smaller.each do |obj|
			result.add(obj) if bigger.include?(obj)
		end
		return result
	end
	alias intersection &

=begin
--- Set#difference(anotherSet) -> aSet
	Returns a new set that contains the contents of this set minus the
	contents of ((|anotherSet|)).
--- Set#-(anotherSet) -> aSet
	Synonym for ((<Set#difference>)).
=end
	def -(another_set)
		result = self.class.new
		each do |obj|
			unless another_set.include?(obj)
				result.add(obj)
			end
		end
		return result
	end
	alias difference -

=begin
--- Set#subset?(anotherSet) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if this set is a subset of ((|anotherSet|)), or if
	this set is equal to ((|anotherSet|)).
=end
	def subset?(another_set)
		return false if length > another_set.length
		each do |obj|
			return false if not another_set.include?(obj)
		end
		return true
	end

=begin
--- Set#proper_subset?(anotherSet) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if this set is a proper subset of ((|anotherSet|)).
	This method differs from ((<Set#subset?>)) in that it returns
	((|false|)) if this	set is equal to ((|anotherSet|))
=end
	def proper_subset?(another_set)
		return false if length >= another_set.length
		return subset?(another_set)
	end

=begin
--- Set#superset?(anotherSet) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if this set is a superset of ((|anotherSet|)), or if
	this set is equal to ((|anotherSet|)).
=end
	def superset?(another_set)
		return another_set.subset?(self)
	end

=begin
--- Set#proper_superset?(anotherSet) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if this set is a proper superset of ((|anotherSet|)).
	This method differs from ((<Set#superset?>)) in that it returns false if
	this set is equal to ((|anotherSet|)).
=end
	def proper_superset?(another_set)
		return false if length <= another_set.length
		return another_set.subset?(self)
	end

=begin
--- Set#==(anotherSet) -> ((|true|)) or ((|false|))
	Returns ((|true|)) if this set contains the same elements as
	((|anotherSet|)).  More precisely, (({set1 == set2})) implies that
	(({set1.length == set2.length})) and that for each element e1 in set1,
	there is exactly one element e2 in set2 such that (({e1.eql?(e2)})).
--- Set#eql?(anotherSet) -> ((|true|)) or ((|false|))
	Synonym for ((<Set#==>)).
=end
	def eql?(another_set)
		return length == another_set.length && subset?(another_set)
	end
	alias == eql?
end
