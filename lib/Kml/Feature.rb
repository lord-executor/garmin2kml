
require("rexml/document")
require("Kml/Object")

module Kml
	
	class Feature < Object
	
		xml_text_accessor(:name, :description, :visibility, :styleUrl)
		attr_reader(:styles)
		
		def initialize(typeName)
			super(typeName)
			
			@styles = []
		end
		
		def add_style(style)
			@styles << style
			self.xmlElement.add_element(style.xmlElement)
		end
		
		def remove_style(style)
			@styles.delete(style)
			self.xmlElement.delete_element(style.xmlElement)
		end
	
	end
	
end
