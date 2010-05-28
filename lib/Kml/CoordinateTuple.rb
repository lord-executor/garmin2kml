
module Kml
	
	class CoordinateTuple
		attr_accessor(:longitude, :latitude, :altitude)
		
		def initialize(longitude, latitude, altitude)
			self.longitude, self.latitude, self.altitude = longitude, latitude, altitude
		end
		
		def to_s
			return "#{self.longitude},#{self.latitude},#{self.altitude}"
		end
		
	end
	
end
