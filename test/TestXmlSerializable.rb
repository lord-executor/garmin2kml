
require("test/Common")
require("rexml/document")
require("Xml/XmlSerializable/XmlSerializable")
require("Xml/XmlSerializable/Serializer")

class NestedObject
	extend(XmlSerializable)
	
	attr_accessor(:text)
	
	xml_namespace(nil, "http://www.test.org/nested")
	xml_text(:@text)
end

class RootObject
	extend(XmlSerializable)
	
	attr_accessor(:element, :nested, :attribute, :array)
	
	xml_namespace(nil, "http://www.test.org/")
	xml_namespace("test", "http://www.test.org/test")
	
	xml_element(:@element, "test", "element", String)
	xml_element(:@nested, nil, "nested", NestedObject)
	xml_attribute(:@attribute, "test", "attribute", Integer)
	xml_array(:@array, "test", "array", String, "arrayElement")
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
	
	def test_out()
		RootObject.print_metadata()
		
		root = RootObject.new()
		root.element = "element text"
		root.attribute = "attribute text"
		root.array = ["array element 1", "array element 2"]
		root.nested = NestedObject.new
		root.nested.text = "nested text"
		
		serializer = XmlSerializable::Serializer.new()
		serializedRoot = serializer.serialize(root, nil, "myroot")
		
		puts(serializedRoot)
	end
	
end

