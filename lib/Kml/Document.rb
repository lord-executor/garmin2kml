
require("Xml/XmlSerializable/XmlSerializable")
require("Kml/Container")
require("Kml/Feature")
require("Kml/Placemark")

module Kml

	class Document < Container
		attr_accessor(:name, :description)
		
		xml_element(:@name, nil, "name", String)
		xml_element(:@description, nil, "description", String)
	end

end
