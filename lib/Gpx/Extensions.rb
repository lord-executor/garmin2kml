
require("Xml/XmlSerializable/XmlSerializable")
require("Gpx/TrackPointExtensions")

module Gpx

	class Extensions
		extend(XmlSerializable)
		
		attr_accessor(:track_point_extensions)
		
		xml_element(:@track_point_extensions, "tpe", "TrackPointExtension", TrackPointExtensions, true)
	end

end
