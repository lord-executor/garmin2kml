
require("Xml/XmlSerializable/XmlSerializable")

module Gpx

	class TrackPoint
		extend(XmlSerializable)
		
		attr_accessor(:latitude, :longitude, :elevation, :time)
		
		xml_attribute(:@latitude, "lat", Float)
		xml_attribute(:@longitude, "lon", Float)
		xml_element(:@elevation, "ele", Float)
		xml_element(:@time, "time", String)
	end

end
