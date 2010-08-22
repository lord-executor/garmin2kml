
require("Xml/XmlSerializable/XmlSerializable")
require("Gpx/TrackSegment")

module Gpx

	class Track
		extend(XmlSerializable)
		
		attr_accessor(:name, :segments)
		
		xml_element(:@name, "name", String)
		xml_array(:@segments, "trkseg", TrackSegment)
	end

end
