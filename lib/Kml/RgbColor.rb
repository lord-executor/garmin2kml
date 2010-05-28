
require("Kml/Color.rb")

module Kml

	class RgbColor
		
		include(Color)
		
		attr_accessor(:red, :green, :blue, :alpha)
		
		def initialize(r, g, b, a = 1.0)
			@red, @green, @blue, @alpha = r, g, b, a
		end
		
		def to_abgr_hex()
			return normalized_to_hex(@alpha, @blue, @green, @red)
		end
		
		def to_rgba_hex()
			return normalized_to_hex(@red, @green, @blue, @alpha)
		end
		
	end
	
end
