module Enumerable
  # Fixnum()
  #
  # Return the number of elements of the Enumerable. Same as _size_ but not all
  # Enumerables implement size.
  #--
  # Should we call the methods _size_?
  def length
    inject(0) do |sum,v|
      sum + 1
    end
  end
end
