
require("libxml")

module XmlSerializable
	
	class Serializer
		
		def serialize(obj, name="element")
			element = LibXML::XML::Node.new(name)
			
			if (obj.class.kind_of?(XmlSerializable))
				obj.class.each_property() do |meta|
					case meta[:xml_type]
						when :text
							element << serialize_basic_type(obj.instance_variable_get(meta[:attribute]))
						when :attribute
							element[meta[:name]] = serialize_basic_type(obj.instance_variable_get(meta[:attribute]))
						when :element
							element << serialize(obj.instance_variable_get(meta[:attribute]), meta[:name])
						when :array
							if (meta[:inner_name] == nil)
								array_element = element
							else
								array_element = LibXML::XML::Node.new(meta[:name])
								element << array_element
							end
							
							inner_name = meta[:inner_name] == nil ? meta[:name] : meta[:inner_name]
							array = obj.instance_variable_get(meta[:attribute])
							if (array != nil)
								array.each do |item|
									array_element << serialize(item, inner_name)
								end
							end
						else
							raise("Unknown XML meta property type #{meta[:xml_type]}")
					end
				end
			else
				element << serialize_basic_type(obj)
			end
			
			return element
		end
		
		def deserialize(element, type)
			if (type.kind_of?(XmlSerializable))
				obj = type.new()
				
				obj.class.each_property() do |meta|
					case meta[:xml_type]
						when :text
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], element.content))
						when :attribute
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], element[meta[:name]]))
						when :element
							obj.instance_variable_set(meta[:attribute], deserialize(get_element(element, [meta[:name]]), meta[:type]))
						when :array
							array = []
							element_path = meta[:inner_name] == nil ? [meta[:name]] : [meta[:name], meta[:inner_name]]
							get_elements(element, element_path) do |item|
								array << deserialize(item, meta[:type])
							end
							obj.instance_variable_set(meta[:attribute], array)
						else
							raise("Unknown XML meta property type #{meta[:xml_type]}")
					end
				end
			else
				obj = deserialize_basic_type(type, element.content)
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
		
		def get_element(node, path_segments)
			segment = path_segments[0]
			
			ns = (node.namespaces.default == nil ? nil : "default:#{node.namespaces.default}")
			current = node.find_first("default:#{segment}", ns)
			
			if (path_segments.length > 1)
				return get_element(current, path_segments.drop(1))
			else
				return current
			end
		end
		
		def get_elements(node, path_segments, &block)
			segment = path_segments[0]
			
			ns = (node.namespaces.default == nil ? nil : "default:#{node.namespaces.default}")
			node.find("default:#{segment}", ns).each do |child|
				if (path_segments.length > 1)
					get_elements(child, path_segments.drop(1), block)
				else
					block.call(child)
				end
			end
		end
		
	end
	
end