
require("Kml/StyleSelector")
require("Kml/IconStyle")
require("Kml/LineStyle")

module Kml

	class Style < StyleSelector
		attr_accessor(:icon_style, :line_style)
		
		xml_element(:@icon_style, nil, "IconStyle", IconStyle, false)
		xml_element(:@line_style, nil, "LineStyle", LineStyle, false)
	end
	
end
