
require("XmlSerializable/XmlSerializable")
require("Gpx/TrackPoint")

module Gpx

	class TrackSegment
		extend(XmlSerializable)
		
		attr_accessor(:points)
		
		xml_array(:@points, nil, "trkpt", TrackPoint)
	end

end
