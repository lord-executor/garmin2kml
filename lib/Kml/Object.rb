
require("rexml/document")

module Kml
	
	class Object
	
		attr_accessor(:xmlElement)
		
		def self.xml_text_accessor(*symbols)
			symbols.each do |sym|
				define_method("#{sym}") do
					get_xml_text_value(sym.to_s)
				end
				define_method("#{sym}=") do |value|
					set_xml_text_value(sym.to_s, value)
				end
			end
		end
		
		def initialize(elementName)
			self.xmlElement = Element.new(elementName)
			@id = nil
		end
		
		def id()
			return @id
		end
		
		def id=(id)
			@id = id
			self.xmlElement.attributes["id"] = @id
		end
		
		def get_xml_text_value(nodeName)
			node = xmlElement.elements[1, nodeName]
			return node.text if node != nil
			return nil
		end
		
		def set_xml_text_value(nodeName, value)
			node = xmlElement.elements[1, nodeName]
			if (node == nil) then
				node = xmlElement.add_element(nodeName)
			end
			node.text = value
		end
	end

end
