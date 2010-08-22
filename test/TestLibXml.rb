
require("test/Common")
require("libxml")

class TestLibXml < Test::Unit::TestCase
	
	def setup()
		
		current_dir = File.expand_path(File.dirname(__FILE__))
		@doc = LibXML::XML::Document.file("#{current_dir}/files/sample.gpx")
		assert_not_nil(@doc, "Unable to load files/sample.gpx")
		
	end
	
	def test_load_file()
		doc = load_sample_file()
		
		assert_not_nil(doc, "Unable to load sample document")
	end
	
	def test_basic_structure()
		doc = load_sample_file()
		
		assert_equal("gpx", doc.root.name, "Sample file root node should be 'gpx'")
		assert_equal("http://www.topografix.com/GPX/1/1", doc.root.namespaces.default.href, "Unexpected root namespace")
		
		doc.root.namespaces.default_prefix = "gpx";
		
		assert_equal(2, doc.find("/gpx:gpx/gpx:trk/gpx:trkseg").length, "Should have exactly 2 track segments")
	end
	
	def test_element_access()
		doc = load_sample_file()
		doc.root.namespaces.default_prefix = "gpx";
		
		name = doc.find_first("/gpx:gpx/gpx:trk/gpx:name")
		assert_not_nil(name, "/gpx/trk/name should not be nil")
		assert_equal("Track Name", name.content)
	end
	
	def test_attribute_access()
		doc = load_sample_file()
		doc.root.namespaces.default_prefix = "gpx";
		
		trackPoint = doc.find_first("/gpx:gpx/gpx:trk/gpx:trkseg/gpx:trkpt")
		assert_not_nil(trackPoint, "/gpx/trk/trkseg/trkpt should not be nil")
		
		attribute = trackPoint.attributes.get_attribute("lat")
		assert_not_nil(attribute, "Trackpoint should have a 'lat' attribute")
		assert_not_equal(0, attribute.value.length)
	end
	
	private
	
	def load_sample_file()
		
		current_dir = File.expand_path(File.dirname(__FILE__))
		doc = LibXML::XML::Document.file("#{current_dir}/files/sample.gpx")
		return doc
		
	end
	
end
