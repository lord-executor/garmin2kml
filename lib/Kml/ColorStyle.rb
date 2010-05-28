
require("rexml/document")
require("Kml/Object")

module Kml

	class ColorStyle < Object
	
		xml_text_accessor(:color, :colorMode)
		
		def initialize(typeName)
			super(typeName)
		end
		
	end
	
end
