
module Kml

	class HsvColor
		
		attr_accessor(:hue, :saturation, :value, :alpha)
		
		def initialize(h, s, v, a = 1.0)
			self.hue, self.saturation, self.value, self.alpha = h, s, v, a
		end
		
		def to_kml_hex_color()
			h_i = (self.hue).div(1.0/6.0)
			f = (self.hue / (1.0/6.0)) - h_i
			p = self.value * (1 - self.saturation)
			q = self.value * (1 - self.saturation * f)
			t = self.value * (1 - self.saturation * (1 - f))
			#puts "#{h_i} #{f} #{p} #{q} #{t}"
			
			case h_i
				when 1
					return denormalize(q, self.value, p, self.alpha)
				when 2
					return denormalize(p, self.value, t, self.alpha)
				when 3
					return denormalize(p, q, self.value, self.alpha)
				when 4
					return denormalize(t, p, self.value, self.alpha)
				when 5
					return denormalize(self.value, p, q, self.alpha)
				else
					return denormalize(self.value, t, p, self.alpha)
			end
		end
		
		private
		
		def denormalize(r, g, b, a)
			return "#{normalized2hex(a)}#{normalized2hex(b)}#{normalized2hex(g)}#{normalized2hex(r)}" 
		end
		
		def normalized2hex(normalized)
			(normalized * 255).floor().to_s(16).rjust(2, "0")
		end
		
	end
	
end
