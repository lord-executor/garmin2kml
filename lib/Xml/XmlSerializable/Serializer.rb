
require("rexml/document")

module XmlSerializable
	
	class Serializer
		
		def serialize(obj, name="element")
			element = REXML::Element.new(name)
			
			if (obj.class.kind_of?(XmlSerializable))
				obj.class.each_property() do |meta|
					case meta[:xml_type]
						when :text
							element.text = serialize_basic_type(obj.instance_variable_get(meta[:attribute]))
						when :attribute
							element.add_attribute(meta[:name], serialize_basic_type(obj.instance_variable_get(meta[:attribute])))
						when :element
							element.add_element(serialize(obj.instance_variable_get(meta[:attribute]), meta[:name]))
						when :array
							array_element = meta[:inner_name] == nil ? element : element.add_element(REXML::Element.new(meta[:name]))
							inner_name = meta[:inner_name] == nil ? meta[:name] : meta[:inner_name]
							array = obj.instance_variable_get(meta[:attribute])
							if (array != nil)
								array.each do |item|
									array_element.add_element(serialize(item, inner_name))
								end
							end
						else
							raise("Unknown XML meta property type #{meta[:xml_type]}")
					end
				end
			else
				element.text = serialize_basic_type(obj)
			end
			
			return element
		end
		
		def deserialize(element, type)
			if (type.kind_of?(XmlSerializable))
				obj = type.new()
				
				obj.class.each_property() do |meta|
					case meta[:xml_type]
						when :text
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], element.text))
						when :attribute
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], element.attributes[meta[:name]]))
						when :element
							obj.instance_variable_set(meta[:attribute], deserialize(element.get_elements(meta[:name]).first(), meta[:type]))
						when :array
							array = []
							element_path = meta[:inner_name] == nil ? meta[:name] : "#{meta[:name]}/#{meta[:inner_name]}"
							element.each_element(element_path) do |item|
								array << deserialize(item, meta[:type])
							end
							obj.instance_variable_set(meta[:attribute], array)
						else
							raise("Unknown XML meta property type #{meta[:xml_type]}")
					end
				end
			else
				obj = deserialize_basic_type(type, element.text)
			end
			
			return obj
		end
		
		private
		
		def serialize_basic_type(obj)
			if (obj.kind_of?(String))
				return obj
			end
			if (obj.kind_of?(Numeric))
				return obj.to_s()
			end
			
			raise("Objects of type #{obj.class} are not supported by this serializer")
		end
		
		def deserialize_basic_type(type, str)
			if (type.ancestors.include?(String))
				return str
			end
			if (type.ancestors.include?(Numeric))
				return Kernel.send(type.to_s(), str)
			end
			
			raise("Objects of type #{type} are not supported by this serializer")
		end
		
	end
	
end