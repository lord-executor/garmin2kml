
require("Kml/Object")

module Kml

	class ColorStyle < Object
		attr_accessor(:color, :color_mode)
		
		xml_element(:@color, nil, "color", String, false)
		xml_element(:@color_mode, nil, "colorMode", String, false)
	end
	
end
