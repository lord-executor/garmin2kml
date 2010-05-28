
require("rexml/document")
require("Kml/Container")

module Kml

	class Document < Container
		
		attr_accessor :xmlDoc
		
		def initialize()
			super("Document")
			
			@xmlDoc = REXML::Document.new()
			@xmlDoc.add(XMLDecl.new("1.0", "utf-8"))
			@kmlRoot = @xmlDoc.add_element("kml", { "xmlns" => "http://www.opengis.net/kml/2.2"} )
			
			@kmlDocument = @kmlRoot.add_element(self.xmlElement)
		end
		
	end

end
