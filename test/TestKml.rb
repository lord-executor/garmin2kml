
require("test/Common")
require("libxml")
require("XmlSerializable/Serializer")
require("Kml/Root")

class TestKml < Test::Unit::TestCase
	
	def setup()
		#current_dir = File.expand_path(File.dirname(__FILE__))
		#doc = LibXML::XML::Document.file("#{current_dir}/files/sample.gpx")
		#serializer = XmlSerializable::Serializer.new()
		#@kml_root = serializer.deserialize(doc.root, Kml::Root)
	end
	
	def test_one()
		point = Kml::Point.new()
		point.position = Kml::CoordinateTuple.new(12, 13, 14)
		
		line = Kml::LineString.new()
		line.add_tuple(Kml::CoordinateTuple.new(1, 2, 3))
		line.add_tuple(Kml::CoordinateTuple.new(4, 5, 6))
		line.add_tuple(Kml::CoordinateTuple.new(7, 8, 9))
		
		placemark = Kml::Placemark.new()
		placemark.geometry = [point, line]
		
		serializer = XmlSerializable::Serializer.new()
		element = serializer.create_element(placemark, nil, "Placemark")
	end
	
end
