
require("Xml/XmlSerializable/XmlSerializable")
require("Gpx/Track")

module Gpx

	class Root
		extend(XmlSerializable)
		
		attr_accessor(:tracks)
		
		xml_namespace(nil, "http://www.topografix.com/GPX/1/1")
		xml_namespace("tc", "http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2")
		xml_namespace("tpe", "http://www.garmin.com/xmlschemas/TrackPointExtension/v1")
		xml_array(:@tracks, nil, "trk", Track)
	end

end
