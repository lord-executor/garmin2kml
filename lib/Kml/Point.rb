
require("rexml/document")
require("Kml/Geometry")

module Kml
	
	class Point < Geometry
	
		xml_text_accessor(:extrude, :altitudeMode)
		
		def initialize()
			super("Point")
			@position = nil
		end
		
		def position
			return @position
		end
		
		def position=(position)
			@position = position
			set_xml_text_value("coordinates", position.to_s)
		end
		
	end
	
end
