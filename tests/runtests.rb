require 'test/unit'
require 'test/unit/ui/console/testrunner'

Dir["Test*.rb"].each do |file|
  system("ruby -w -I../lib #{file}")
end
