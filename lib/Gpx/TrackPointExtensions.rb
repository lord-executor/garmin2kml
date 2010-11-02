
require("Xml/XmlSerializable/XmlSerializable")

module Gpx

	class TrackPointExtensions
		extend(XmlSerializable)
		
		attr_accessor(:heart_rate)
		
		xml_element(:@heart_rate, "tpe", "hr", Integer)
	end

end
