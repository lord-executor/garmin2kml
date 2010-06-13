
require("test/Common")
require("rexml/document")
require("Xml/Formatters/Reasonable")

class TestReasonable < Test::Unit::TestCase
	
	def test_initialize()
		
		assert_nothing_raised("Reasonable.new() raised an exception") do
			Xml::Formatters::Reasonable.new()
		end
		
	end
	
end
