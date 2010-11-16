
require("Kml/Feature")

module Kml

	class Container < Feature
		attr_accessor(:features)
		
		xml_array_polymorph(:@features, Feature)
		
		def initialize()
			@features = []
		end
	end
	
end
