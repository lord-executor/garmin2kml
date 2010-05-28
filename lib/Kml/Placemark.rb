
require("rexml/document")
require("Kml/Feature")

module Kml

	class Placemark < Feature
		
		def initialize()
			super("Placemark")
			@geometry = nil
		end
		
		def geometry()
			return @geometry
		end
		
		def geometry=(geometry)
			if (@geometry != nil) then
				self.xmlElement.delete_element(@geometry.xmlElement)
			end
			
			@geometry = geometry
			self.xmlElement.add_element(@geometry.xmlElement)
		end
		
	end

end