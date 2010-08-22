
require("Xml/XmlSerializable/XmlSerializable")
require("Xml/XmlSerializable/Serializer")
require("Gpx/Track")

module Gpx

	class Root
		extend(XmlSerializable)
		
		attr_accessor(:tracks)
		
		xml_array(:@tracks, "trk", Track)
	end

end
