class Array
  alias add push
end

unless Enumerable.instance_methods(true).grep(/inject/)
  module Enumerable
    def inject(*argv)
      argc = argv.size

      if argc == 0
        first = true
        result = nil

        each { |e|
          if first
            first = false
            result = e
          else
            result = yield(result, e)
          end
        }
      elsif argc == 1
        result = argv[0]

        each { |e| result = yield(result, e) }
      else
        raise ArgumentError, "wrong # of arguments(#{argc} for 1)"
      end

      result
    end
  end
end  

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
