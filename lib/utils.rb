# 
# $Id$
# 
# _inject_ is now included in knus compatibility library for Ruby 1.8 (see
# http://www.ruby-lang.org/en/raa-list.rhtml?name=Ruby+Shim+for+1.6). We only
# define here the method _length_ for Enumerable which perhaps could also be
# included in Enumerable?
# 
require 'features/ruby18/enumerable'

module Enumerable
  # Fixnum()
  #
  # Return the number of elements of the Enumerable. Same as _size_ but not all
  # Enumerables implement size.
  #
  # Should we call the methods _size_?
  def length
	inject (0) do |sum,v|
	  sum + 1
	end
  end
end
