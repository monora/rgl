require 'test/unit'
require 'test/unit/ui/console/testrunner'

class AllBuiltinTests  
  def AllBuiltinTests.suite
    suite = Test::Unit::TestSuite.new("RGL Testsuite")
    Dir["Test*.rb"].each { |file|
      require file
      suite.add(eval(file.sub(/\.rb$/, '')).suite)
    }
    suite
  end
end

Test::Unit::UI::Console::TestRunner.run(AllBuiltinTests)
