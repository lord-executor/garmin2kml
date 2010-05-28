
require("rexml/document")
require("Kml/ColorStyle")

module Kml

	class IconStyle < ColorStyle
		
		xml_text_accessor(:scale,:heading)
		attr_reader(:icon)
		
		def initialize()
			super("IconStyle")
			@icon = nil
		end
		
		def icon()
			return @icon
		end
		
		def icon=(icon)
			if (@icon != nil) then
				self.xmlElement.delete_element(@icon.xmlElement)
			end
			
			@icon = icon
			self.xmlElement.add_element(@icon.xmlElement)
		end
		
	end
	
end
