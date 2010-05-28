
require("rexml/document")
require("Kml/Object")

module Kml

	class Icon < Object
	
		xml_text_accessor(:href)
		
		def initialize()
			super("Icon")
		end
		
	end
	
end
