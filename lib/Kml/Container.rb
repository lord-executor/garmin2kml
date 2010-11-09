
require("Xml/XmlSerializable/XmlSerializable")
require("Kml/Feature")

module Kml

	class Container < Feature
		attr_accessor(:features)
		
		xml_array_polymorph(:@features, Feature)	
	end
	
end
