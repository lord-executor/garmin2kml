
module XmlSerializable
	
	class XmlName
		
		attr_accessor(:prefix, :uri)
		
		def initialize(prefix, uri)
			@prefix = prefix
			@uri = uri
		end
		
		def full_name()
			return "#{prefix}:#{uri}"
		end
		
	end
	
end