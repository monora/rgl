# Some helper utilities used in test classes

class Array
  # We need Array#add in test classes to be able to use Arrays as adjacency lists
  # This is needed to have ordered lists as neigbors in our test graphs.
  alias add push
end
