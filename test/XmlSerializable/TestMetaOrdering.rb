
require("test/Common")
require("libxml")
require("XmlSerializable/XmlSerializable")
require("XmlSerializable/Serializer")

module MetaOrderingSamples

	class RootObject
		extend(XmlSerializable)
		
		attr_accessor(:element1, :attribute1)
		
		xml_element(:@element1, nil, "element1", String)
		xml_attribute(:@attribute1, nil, "attribute1", String)
	end
	
	class DerivedAppend < RootObject
		attr_accessor(:element2, :attribute2)
		
		xml_element(:@element2, nil, "element2", String)
		xml_attribute(:@attribute2, nil, "attribute2", String)
	end
	
	class DerivedPrepend < RootObject
		attr_accessor(:element2, :attribute2)
		
		xml_prepend()
		xml_element(:@element2, nil, "element2", String)
		xml_attribute(:@attribute2, nil, "attribute2", String)
	end
	
	class DerivedMixed < RootObject
		attr_accessor(:element2, :attribute2, :element3, :attribute3)
		
		xml_prepend()
		xml_element(:@element2, nil, "element2", String)
		xml_append()
		xml_attribute(:@attribute2, nil, "attribute2", String)
		xml_element(:@element3, nil, "element3", String)
		xml_prepend()
		xml_attribute(:@attribute3, nil, "attribute3", String)
	end
	
end

class TestMetaOrdering < Test::Unit::TestCase
	
	def test_root()
		meta_collection = MetaOrderingSamples::RootObject.get_xml_metadata()
		assert_equal(2, meta_collection.length)
		assert_equal([:@element1, :@attribute1], meta_collection.map { |meta| meta[:attribute] })
	end
	
	def test_derived_append()
		meta_collection = MetaOrderingSamples::DerivedAppend.get_xml_metadata()
		assert_equal(4, meta_collection.length)
		assert_equal([:@element1, :@attribute1, :@element2, :@attribute2], meta_collection.map { |meta| meta[:attribute] })
	end
	
	def test_derived_prepend()
		meta_collection = MetaOrderingSamples::DerivedPrepend.get_xml_metadata()
		assert_equal(4, meta_collection.length)
		assert_equal([:@attribute2, :@element2, :@element1, :@attribute1], meta_collection.map { |meta| meta[:attribute] })
	end
	
	def test_derived_mixed()
		meta_collection = MetaOrderingSamples::DerivedMixed.get_xml_metadata()
		assert_equal(6, meta_collection.length)
		assert_equal([:@attribute3, :@element2, :@element1, :@attribute1, :@attribute2, :@element3], meta_collection.map { |meta| meta[:attribute] })
	end
	
end
