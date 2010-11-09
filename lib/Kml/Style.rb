
require("Xml/XmlSerializable/XmlSerializable")
require("Kml/StyleSelector")
require("Kml/IconStyle")
require("Kml/LineStyle")

module Kml

	class Style < StyleSelector
		attr_accessor(:iconStyle, :lineStyle)
		
		xml_element(:@icon_style, nil, "iconStyle", IconStyle)
		xml_element(:@line_style, nil, "lineStyle", LineStyle)
	end
	
end
