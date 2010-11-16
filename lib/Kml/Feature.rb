
require("Kml/Object")
require("Kml/Style")

module Kml
	
	class Feature < Object
		attr_accessor(:name, :description, :visibility, :style_url, :styles)
		
		xml_element(:@name, nil, "name", String, false)
		xml_element(:@description, nil, "description", String, false)
		xml_element(:@visibility, nil, "visibility", String, false)
		xml_element(:@style_url, nil, "styleUrl", String, false)
		xml_array_polymorph(:@styles, Style, false)
	end
	
end
