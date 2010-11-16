
require("Kml/Feature")
require("Kml/Geometry")

module Kml

	class Placemark < Feature
		attr_accessor(:geometry)
		
		xml_array_polymorph(:@geometry, Geometry)
	end

end