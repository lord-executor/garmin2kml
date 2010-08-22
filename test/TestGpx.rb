
require("test/Common")
require("Gpx/Root")
require("rexml/document")

class TestGpx < Test::Unit::TestCase
	
	def setup()
		
	end
	
	def test_load_file()
		current_dir = File.expand_path(File.dirname(__FILE__))
		doc = REXML::Document.new(File.new("#{current_dir}/files/sample.gpx"))
		
		serializer = XmlSerializable::Serializer.new()
		gpx_root = serializer.deserialize(doc.root, Gpx::Root)
		
		assert_equal(1, gpx_root.tracks.length, "Sample file should have one track")
		assert_equal("Track Name", gpx_root.tracks[0].name, "Sample track name expected to be 'Track Name'")
	end
	
end
