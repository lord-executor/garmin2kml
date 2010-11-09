
require("Xml/XmlSerializable/XmlSerializable")
require("Kml/Geometry")

module Kml
	
	class LineString < Geometry
		attr_accessor(:extrude, :tessellate, :altitude_mode)
		
		xml_element(:@extrude, nil, "extrude", Integer, false)
		xml_element(:@tesselate, nil, "tesselate", Integer, false)
		xml_element(:@altitude_mode, nil, "altitudeMode", String, false)
		xml_element(:@coordinates, nil, "coordinates", String)
		
		def initialize()
			@tuples = []
		end
		
		def add_tuple(tuple)
			@tuples << tuple
			set_coordinates()
		end
		
		def remove_tuple(tuple)
			@tuples.delete(tuple)
			set_coordinates()
		end
		
		private
		
		def set_coordinates()
			serialized = ""
			@tuples.each do |tuple|
				serialized << tuple.to_s << "\n"
			end
			@coordinates = serialized
		end
		
	end
	
end
