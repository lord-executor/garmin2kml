
require("XmlSerializable/XmlSerializable")
require("Gpx/TrackSegment")

module Gpx

	class Track
		extend(XmlSerializable)
		
		attr_accessor(:name, :segments)
		
		xml_element(:@name, nil, "name", String)
		xml_array(:@segments, nil, "trkseg", TrackSegment)
	end

end
