
require("test/Common")
require("libxml")
require("XmlSerializable/XmlSerializable")
require("XmlSerializable/Serializer")

module XmlSerializableSamples

	class BaseObject
		extend(XmlSerializable)
		
		attr_accessor(:base)
		
		xml_attribute(:@base, nil, "base", String)
	end

	class DerivedObjectOne < BaseObject
		attr_accessor(:one)
		
		xml_text(:@one)
	end

	class DerivedObjectTwo < BaseObject
		attr_accessor(:two)
		
		xml_text(:@two)
	end

	class DerivedObjectThree < DerivedObjectOne
		attr_accessor(:three)
		
		xml_attribute(:@three, nil, "three", String)
	end

	class PolyRootObject
		extend(XmlSerializable)
		
		attr_accessor(:children)
		
		xml_array_polymorph(:@children, BaseObject)
	end

end


class TestPolymorphSerializable < Test::Unit::TestCase
	def setup()
		@poly_xml = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<PolyRootObject>
  <DerivedObjectOne base="XmlSerializableSamples::DerivedObjectOne">value one</DerivedObjectOne>
  <DerivedObjectTwo base="XmlSerializableSamples::DerivedObjectTwo">value two</DerivedObjectTwo>
  <DerivedObjectThree base="XmlSerializableSamples::DerivedObjectThree" three="attribute three">value three</DerivedObjectThree>
</PolyRootObject>
EOS
	end
	
	def test_hierarchy()
		assert_equal([], [XmlSerializableSamples::DerivedObjectOne, XmlSerializableSamples::DerivedObjectTwo, XmlSerializableSamples::DerivedObjectThree] - XmlSerializableSamples::BaseObject.get_subclasses())
		assert_equal([], [XmlSerializableSamples::DerivedObjectThree] - XmlSerializableSamples::DerivedObjectOne.get_subclasses())
		assert_equal([], XmlSerializableSamples::DerivedObjectTwo.get_subclasses())
	end
	
	def test_meta_inheritance()
		assert_raise(RuntimeError) do
			Class.new(XmlSerializableSamples::DerivedObjectOne) do
				xml_text(:@random_attribute)
			end
		end
	end
	
	def test_serialization()
		one = XmlSerializableSamples::DerivedObjectOne.new()
		one.base = one.class.to_s()
		one.one = "value one"
		
		two = XmlSerializableSamples::DerivedObjectTwo.new()
		two.base = two.class.to_s()
		two.two = "value two"
		
		three = XmlSerializableSamples::DerivedObjectThree.new()
		three.base = three.class.to_s()
		three.one = "value three"
		three.three = "attribute three"
		
		root = XmlSerializableSamples::PolyRootObject.new()
		root.children = [one, two, three]
		
		serializer = XmlSerializable::Serializer.new()
		doc = serializer.create_document(root, nil, nil)
		assert_equal(@poly_xml, doc.to_s())
	end
	
	def test_deserialize()
		doc = LibXML::XML::Document.string(@poly_xml)
		serializer = XmlSerializable::Serializer.new()
		root = serializer.from_document(doc, XmlSerializableSamples::PolyRootObject)
		
		assert_equal(3, root.children.length)
		root.children.each() do |obj|
			assert_equal(obj.base, obj.class.to_s())
		end
		assert_equal("value one", root.children[0].one)
		assert_equal("value two", root.children[1].two)
		assert_equal("value three", root.children[2].one)
		assert_equal("attribute three", root.children[2].three)
	end
	
end

