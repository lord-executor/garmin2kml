
require("rexml/document")
require("Kml/Feature")

module Kml

	class Container < Feature
	
		attr_reader(:features)
		
		def initialize(typeName)
			super(typeName)
			@features = []
		end
		
		def add_feature(feature)
			xmlElement.add_element(feature.xmlElement)
			self.features << feature
		end
		
		def remove_feature(feature)
			xmlElement.delete_element(feature.xmlElement)
			self.features.delete(feature)
		end
	
	end
	
end
