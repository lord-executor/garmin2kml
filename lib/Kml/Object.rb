
require("Xml/XmlSerializable/XmlSerializable")

module Kml
	
	class Object
		extend(XmlSerializable)
		attr_accessor(:id)
		
		xml_attribute(:@id, nil, "id", String, false)
	end

end
