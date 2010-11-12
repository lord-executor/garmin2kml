
module Garmin2Kml

	module Util
		
		module Color
			
			def normalized_to_hex(*normalized_values)
				hex = ""
				normalized_values.each do |value|
					raise("Normalized value [0, 1] expected") if !value.between?(0.0, 1.0)
					hex << byte_to_hex((value * 255).floor())
				end
				return hex
			end
			
			private
			
			def byte_to_hex(byte)
				byte.to_s(16).rjust(2, "0")
			end
			
		end
		
	end
	
end
