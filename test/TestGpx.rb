
require("test/Common")
require("libxml")
require("XmlSerializable/Serializer")
require("Gpx/Root")

class TestGpx < Test::Unit::TestCase
	
	def setup()
		current_dir = File.expand_path(File.dirname(__FILE__))
		doc = LibXML::XML::Document.file("#{current_dir}/files/sample.gpx")
		serializer = XmlSerializable::Serializer.new()
		@gpx_root = serializer.deserialize(doc.root, Gpx::Root)
	end
	
	def test_track()
		assert_not_nil(@gpx_root)
		assert_equal(Gpx::Root, @gpx_root.class, "Deserialization result should be an instance of Gpx::Root")
		assert_equal(1, @gpx_root.tracks.length, "Sample file should have one track")
		assert_equal("Track Name", @gpx_root.tracks[0].name, "Sample track name expected to be 'Track Name'")
	end
	
	def test_segments()
		track =  @gpx_root.tracks[0]
		assert_equal(2, track.segments.length, "Sample track expected to have two segments")
		assert_equal(424, track.segments[0].points.length, "First track segment expected to have 424 points")
		assert_equal(147, track.segments[1].points.length, "Second track segment expected to have 147 points")
	end
	
	def test_track_point()
		point = @gpx_root.tracks[0].segments[0].points[0]
		assert_equal(42.4205350, point.latitude, "Latitude should be 42.4205350")
		assert_equal(12.5350356, point.longitude, "Longitude should be 12.5350356")
		assert_equal(419.2722168, point.elevation, "Elevation should be 12.5350356")
		assert_equal("2010-05-24T10:05:42Z", point.time, "Time should be 2010-05-24T10:05:42Z")
	end
	
	def test_track_point_extensions()
		tpe = @gpx_root.tracks[0].segments[0].points[0].extensions.track_point_extensions
		assert_equal(101, tpe.heart_rate, "Heart rate should be 101")
		tpe = @gpx_root.tracks[0].segments[0].points[1].extensions.track_point_extensions
		assert_equal(102, tpe.heart_rate, "Heart rate should be 102")
		tpe = @gpx_root.tracks[0].segments[0].points[2].extensions.track_point_extensions
		assert_equal(103, tpe.heart_rate, "Heart rate should be 103")
	end
	
end
