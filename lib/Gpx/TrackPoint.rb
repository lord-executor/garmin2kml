
require("XmlSerializable/XmlSerializable")
require("Gpx/Extensions")

module Gpx

	class TrackPoint
		extend(XmlSerializable)
		
		attr_accessor(:latitude, :longitude, :elevation, :time, :extensions)
		
		xml_attribute(:@latitude, nil, "lat", Float)
		xml_attribute(:@longitude, nil, "lon", Float)
		xml_element(:@elevation, nil, "ele", Float)
		xml_element(:@time, nil, "time", String)
		xml_element(:@extensions, nil, "extensions", Extensions)
	end

end
