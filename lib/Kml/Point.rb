
require("Kml/Geometry")

module Kml
	
	class Point < Geometry
		attr_accessor(:extrude, :altitude_mode)
		
		xml_element(:@extrude, nil, "extrude", Integer, false)
		xml_element(:@altitude_mode, nil, "altitudeMode", String, false)
		xml_element(:@coordinates, nil, "coordinates", String)
		
		def initialize()
			@position = nil
		end
		
		def position
			return @position
		end
		
		def position=(position)
			@position = position
			@coordinates = position.to_s
		end
		
	end
	
end
