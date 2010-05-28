
module Kml

	class Color
		
		attr_accessor(:red, :green, :blue, :alpha)
		
		def initialize(r, g, b, a = 1.0)
			self.red, self.green, self.blue, self.alpha = r, g, b, a
		end
		
		def to_kml_hex_color()
			return "#{denormalize(self.alpha)}#{denormalize(self.blue)}#{denormalize(self.green)}#{denormalize(self.red)}"
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
