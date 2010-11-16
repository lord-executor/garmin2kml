
require("Kml/Object")

module Kml

	class Icon < Object
		attr_accessor(:href)
		
		xml_element(:@href, nil, "href", String)
	end
	
end
