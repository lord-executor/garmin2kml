
require("Kml/ColorStyle")
require("Kml/Icon")

module Kml

	class IconStyle < ColorStyle
		attr_accessor(:scale, :heading, :icon)
		
		xml_element(:@scale, nil, "scale", Float)
		xml_element(:@heading, nil, "heading", Integer)
		xml_element(:@icon, nil, "Icon", Icon)
	end
	
end
