
require("test/Common")
require("libxml")
require("XmlSerializable/XmlSerializable")
require("XmlSerializable/Serializer")

module XmlSerializableSamples

	class NestedObject
		extend(XmlSerializable)
		
		attr_accessor(:text)
		
		xml_namespace(nil, "http://www.test.org/nested")
		xml_text(:@text)
	end

	class RootObject
		extend(XmlSerializable)
		
		attr_accessor(:element, :nested, :attribute, :array, :nonsattr, :nonselement)
		
		xml_namespace(nil, "http://www.test.org/")
		xml_namespace("test", "http://www.test.org/test")
		
		xml_attribute(:@attribute, "test", "attribute", Integer, false)
		xml_attribute(:@nonsattr, nil, "nonsattr", String, false)
		xml_element(:@element, "test", "element", String)
		xml_element(:@nonselement, nil, "nonselement", String)
		xml_element(:@nested, nil, "nested", NestedObject, false)
		xml_array(:@array, "test", "array", String, "arrayElement", false)
	end
	
end


class TestXmlSerializable < Test::Unit::TestCase
	
	def setup()
		@xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<myroot xmlns="http://www.test.org/" xmlns:test="http://www.test.org/test" test:attribute="42" nonsattr="no namespace">
  <test:element>element text</test:element>
  <nonselement>no namespace</nonselement>
  <nested xmlns="http://www.test.org/nested">nested text</nested>
  <test:array>
    <arrayElement>array element 1</arrayElement>
    <arrayElement>array element 2</arrayElement>
  </test:array>
</myroot>
EOS
	end
	
	def test_metadata()
		assert_equal(6, XmlSerializableSamples::RootObject.get_xml_metadata().size, "Should have metadata")
		assert_equal(true, XmlSerializableSamples::RootObject.has_element_attribute?(), "Should have element attribute")
		assert_equal(false, XmlSerializableSamples::RootObject.has_text_attribute?(), "Should not have text attribute")
		
		array = XmlSerializableSamples::RootObject.get_xml_metadata().select { |m| m[:name] == "nested" }
		assert_equal(1, array.length, "There should be exactly one element attribute named 'nested'")
		nested = array[0]
		assert_equal(XmlSerializableSamples::NestedObject, nested[:type], "The type of the 'nested' element should be 'NestedObject'")
	end
	
	def test_required()
		serializer = XmlSerializable::Serializer.new()
		
		nested = XmlSerializableSamples::NestedObject.new
		assert_raise(XmlSerializable::RequiredPropertyException) do
			serializer.serialize(nested, nil, "nested")
		end
		nested.text = "nested.text"
		assert_not_nil(serializer.serialize(nested, nil, "nested"))
		
		root = XmlSerializableSamples::RootObject.new()
		root.element = "bla"
		assert_raise(XmlSerializable::RequiredPropertyException) do
			serializer.serialize(root, nil, "root")
		end
		root.nonselement = "more text"
		assert_not_nil(serializer.serialize(root, nil, "root"))
	end
	
	def test_serialize()
		root = XmlSerializableSamples::RootObject.new()
		root.element = "element text"
		root.nonselement = "no namespace"
		root.attribute = 42
		root.nonsattr = "no namespace"
		root.array = ["array element 1", "array element 2"]
		root.nested = XmlSerializableSamples::NestedObject.new()
		root.nested.text = "nested text"
		
		serializer = XmlSerializable::Serializer.new()
		serializedDoc = serializer.create_document(root, nil, "myroot")
		
		assert_equal(@xml, serializedDoc.to_s, "Generated XML markup doesn't match expected value")
	end
	
	def test_deserialize()
		doc = LibXML::XML::Document.string(@xml)
		nested = doc.find_first("/test:myroot/ne:nested", { "test" => "http://www.test.org/", "ne" => "http://www.test.org/nested" })
		serializer = XmlSerializable::Serializer.new()
		root = serializer.from_document(doc, XmlSerializableSamples::RootObject)
		
		assert_equal("element text", root.element)
		assert_equal("no namespace", root.nonselement)
		assert_equal(42, root.attribute)
		assert_equal("no namespace", root.nonsattr)
		assert_equal("nested text", root.nested.text)
	end
	
end

