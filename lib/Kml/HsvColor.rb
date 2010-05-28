
require("Kml/Color.rb")

module Kml

	class HsvColor
		
		include(Color)
		
		attr_accessor(:hue, :saturation, :value, :alpha)
		
		def initialize(h, s, v, a = 1.0)
			@hue, @saturation, @value, @alpha = h, s, v, a
		end
		
		def to_abgr_hex()
			normalized_to_hex(*get_rgba_values().reverse())
		end
		
		def to_rgba_hex()
			normalized_to_hex(*get_rgba_values())
		end
		
		private
		
		def get_rgba_values()
			h_i = (self.hue).div(1.0/6.0)
			f = (self.hue / (1.0/6.0)) - h_i
			p = self.value * (1 - self.saturation)
			q = self.value * (1 - self.saturation * f)
			t = self.value * (1 - self.saturation * (1 - f))
			#puts "#{h_i} #{f} #{p} #{q} #{t}"
			
			case h_i
				when 1
					return [q, @value, p, @alpha]
				when 2
					return [p, @value, t, @alpha]
				when 3
					return [p, q, @value, @alpha]
				when 4
					return [t, p, @value, @alpha]
				when 5
					return [@value, p, q, @alpha]
				else
					return [@value, t, p, @alpha]
			end
		end
		
	end
	
end
