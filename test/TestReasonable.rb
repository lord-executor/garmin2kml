
require("test/Common")
require("rexml/document")
require("Xml/Formatters/Reasonable")



class TestReasonable < Test::Unit::TestCase
	
	def setup()
		@xml = <<EOS
<?xml version='1.0' encoding='UTF-8'?>
<root>
	<sample attribute="value">asdf</sample>
	<anotherSample>
		<test>42</test>
	</anotherSample>
</root>
EOS
		
		@doc = REXML::Document.new()
		root = REXML::Element.new("root")
		sample = REXML::Element.new("sample")
		sample.add_attribute("attribute", "value")
		sample.text = "asdf"
		test = REXML::Element.new("test")
		test.text = "42"
		another_sample = REXML::Element.new("anotherSample")
		another_sample << test
		root << sample
		root << another_sample
		@doc << REXML::XMLDecl.new("1.0", "UTF-8")
		@doc << root
	end
	
	def test_initialize()
		
		assert_nothing_raised("Reasonable.new() raised an exception") do
			Xml::Formatters::Reasonable.new()
		end
		
	end
	
	def test_indentation()
		formatter = Xml::Formatters::Reasonable.new(2, " ")
		output = StringIO.new()
		formatter.write(@doc, output)
		xml_space = @xml.gsub(/\t/, "  ")
		
		assert_equal(xml_space, output.string, "Formatted XML does not match original input")
	end
	
	def test_formatter()
		output = get_formatted_output(@doc)
		assert_equal(@xml, output, "Formatted XML does not match original input")
	end
	
	def test_formatter_conservation()
		# read document removing all whitespace-only text nodes
		doc = REXML::Document.new(@xml, { :ignore_whitespace_nodes => :all })
		output = get_formatted_output(doc)
		
		assert_equal(@xml, output, "Formatted XML does not match original input")
	end
	
	private
	
	def get_formatted_output(doc)
		formatter = Xml::Formatters::Reasonable.new()
		output = StringIO.new()
		formatter.write(doc, output)
		return output.string
	end
	
end
