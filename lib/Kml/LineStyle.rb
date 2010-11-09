
require("Xml/XmlSerializable/XmlSerializable")
require("Kml/ColorStyle")

module Kml

	class LineStyle < ColorStyle
		attr_accessor(:width)
		
		xml_element(:@width, nil, "width", Float)
	end
	
end
