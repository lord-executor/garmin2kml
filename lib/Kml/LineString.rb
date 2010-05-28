
require("rexml/document")
require("Kml/Geometry")

module Kml
	
	class LineString < Geometry
	
		xml_text_accessor(:extrude, :tessellate, :altitudeMode)
		attr_reader(:coordinates)
		
		def initialize()
			super("LineString")
			@coordinates = []
		end
		
		def add_tuple(tuple)
			self.coordinates << tuple
			set_coordinates()
		end
		
		def remove_tuple(tuple)
			self.coordinates.delete(tuple)
			set_coordinates()
		end
		
		private
		
		def set_coordinates()
			serialized = ""
			self.coordinates.each do |tuple|
				serialized << tuple.to_s << "\n"
			end
			
			set_xml_text_value("coordinates", serialized)
		end
		
	end
	
end
