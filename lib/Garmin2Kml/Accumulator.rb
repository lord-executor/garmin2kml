
require("Gpx/TrackPoint")

module Garmin2Kml

	class Accumulator
		
		# mean earth radius in kilometers
		RADIUS = 6371
		
		attr_reader(:segment_count,
					:segment_distance, :segment_elevation_up, :segment_elevation_down,
					:total_distance, :total_elevation_up, :total_elevation_down)
		
		def initialize()
			reset()
		end
		
		def reset()
			@segment_count = 0
			@segment_distance = 0
			@segment_elevation_up = 0
			@segment_elevation_down = 0
			@total_distance = 0
			@total_elevation_up = 0
			@total_elevation_down = 0
		end
		
		def reset_segment()
			@segment_count = @segment_count + 1
			@segment_distance = 0
			@segment_elevation_up = 0
			@segment_elevation_down = 0
		end
		
		def add_point(gpx_point)
			if (@last_point != nil)
				d = distance(@last_point, gpx_point)
				h = gpx_point.elevation - @last_point.elevation
				
				@segment_distance += d
				@segment_elevation_up += (h > 0 ? h : 0)
				@segment_elevation_down -= (h < 0 ? h : 0)
				@total_distance += d
				@total_elevation_up += (h > 0 ? h : 0)
				@total_elevation_down -= (h < 0 ? h : 0)
			end
			
			@last_point = gpx_point
		end
		
		def get_segment_stats()
			stats = StringIO.new()
			stats << "Distance: #{@segment_distance} km<br />\n"
			stats << "Elevation: +#{@segment_elevation_up} m / -#{@segment_elevation_down} m<br />\n"
			return stats.string
		end
		
		def get_total_stats()
			stats = StringIO.new()
			stats << "Distance: #{@total_distance} km<br />\n"
			stats << "Elevation: +#{@total_elevation_up} m / -#{@total_elevation_down} m<br />\n"
			return stats.string
		end
		
		private
		
		def distance(point1, point2)
			lat1 = point1.latitude.to_f() / 180.0 * Math::PI
			lat2 = point2.latitude.to_f() / 180.0 * Math::PI
			lon1 = point1.longitude.to_f() / 180.0 * Math::PI
			lon2 = point2.longitude.to_f() / 180.0 * Math::PI
			
			delta_lat = lat2 - lat1
			delta_lon = lon2 - lon1
			
			a = Math::sin(delta_lat/2) ** 2 + Math::cos(lat1) * Math::cos(lat2) * Math::sin(delta_lon/2) ** 2
			c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
			return RADIUS * c
		end
		
	end

end