def accumulate
  result = Array.new
  yield proc { |x| result << x }
  result
end

module Enumerable
  def length
	inject (0) do |sum,v|
	  sum + 1
	end
  end

  def inject (thisValue)
	each do |x|
	  thisValue = yield thisValue, x
	end
	thisValue
  end
end
