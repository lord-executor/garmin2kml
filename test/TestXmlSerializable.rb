
require("test/Common")
require("rexml/document")
require("Xml/XmlSerializable/XmlSerializable")
require("Xml/XmlSerializable/Serializer")

class NestedObject
	extend(XmlSerializable)
end

class RootObject
	extend(XmlSerializable)
	
	attr_accessor(:element, :nested, :attribute, :array)
	
	xml_element(:@element, "element", String)
	xml_element(:@nested, "nested", NestedObject)
	xml_attribute(:@attribute, "attribute", Integer)
	xml_array(:@array, "array", String, "arrayElement")
end


class TestXmlSerializable < Test::Unit::TestCase
	
	def setup()
	end
	
	def test_metadata()
		assert_equal(4, RootObject.get_xml_metadata().size, "Should have metadata")
		assert_equal(true, RootObject.has_element_attribute?(), "Should have element attribute")
		assert_equal(false, RootObject.has_text_attribute?(), "Should not have text attribute")
		
		array = RootObject.get_xml_metadata().select { |m| m[:name] == "nested" }
		assert_equal(1, array.length, "There should be exactly one element attribute named 'nested'")
		nested = array[0]
		assert_equal(NestedObject, nested[:type], "The type of the 'nested' element should be 'NestedObject'")
	end
	
end

