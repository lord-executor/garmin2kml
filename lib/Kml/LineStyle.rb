
require("rexml/document")
require("Kml/ColorStyle")

module Kml

	class LineStyle < ColorStyle
		
		xml_text_accessor(:width)
		
		def initialize()
			super("LineStyle")
		end
		
	end
	
end
