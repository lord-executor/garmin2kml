
require("Kml/Document")
require("Kml/Feature")
require("Kml/Geometry")
require("Kml/Point")
require("Kml/LineString")
require("Kml/ColorStyle")
require("Kml/Container")
require("Kml/CoordinateTuple")
require("Kml/Icon")
require("Kml/IconStyle")
require("Kml/LineStyle")
require("Kml/Object")
require("Kml/Placemark")
require("Kml/Style")
require("Kml/StyleSelector")

module Kml

	class Root
		extend(XmlSerializable)
		
		attr_accessor(:document)
		
		xml_namespace(nil, "http://www.opengis.net/kml/2.2")
		xml_element(:@document, nil, "Document", Document)
	end

end
