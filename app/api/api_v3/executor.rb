require 'agent_fix'
require 'quickfix'
puts "test1"
#FIXSpec.data_dictionary= quickfix.DataDictionary.new "J/FIX/FIX42.xml" #this is wrong
#FIXSpec.data_dictionary= quickfix.DataDictionary.new "path/to/FIX42.xml"
puts "hello world"
AgentFIX.start
