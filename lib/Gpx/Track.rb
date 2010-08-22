
require("Xml/XmlSerializable/XmlSerializable")
require("Xml/XmlSerializable/Serializer")

module Gpx

	class Track
		extend(XmlSerializable)
		
		attr_accessor(:name, :segments)
		
		xml_element(:@name, "name", String)
		xml_array(:@segments, "trkseg", String)
	end

end
