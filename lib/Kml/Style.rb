
require("rexml/document")
require("Kml/StyleSelector")

module Kml

	class Style < StyleSelector
		
		attr_reader(:iconStyle,:labelStyle,:lineStyle,:polyStyle,:balloonStyle,:listStyle)
		
		def initialize(styleId)
			super("Style")
			
			self.id = styleId
			@iconStyle = nil
			@labelStyle = nil
			@lineStyle = nil
			@polyStyle = nil
			@balloonStyle = nil
			@listStyle = nil
		end
		
		def iconStyle=(iconStyle)
			if @iconStyle != nil then
				self.xmlElement.delete_element(@iconStyle.xmlElement)
			end
			
			@iconStyle = iconStyle
			self.xmlElement.add_element(@iconStyle.xmlElement)
		end
		
		def lineStyle=(lineStyle)
			if @lineStyle != nil then
				self.xmlElement.delete_element(@lineStyle.xmlElement)
			end
			
			@lineStyle = lineStyle
			self.xmlElement.add_element(@lineStyle.xmlElement)
		end
		
	end
	
end
