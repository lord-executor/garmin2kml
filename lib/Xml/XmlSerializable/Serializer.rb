
require("libxml")
require("Xml/XmlSerializable/RequiredPropertyException")

module XmlSerializable
	
	class Serializer
		
		# Creates an XML document from the given object using root_namespace_prefix and
		# root_element_name as NS prefix and element name for the root XML node.
		# Note that the prefix for the root element has to match an XML namespace definition
		# in obj's class definition.
		def create_document(obj, root_namespace_prefix, root_element_name)
			
		end
		
		# Creates an XML node form the given object
		def create_element(obj, prefix, name)
			return serialize(obj, prefix, name)
		end
		
		# Serializes the given object as an XML element with the provided namespace prefix and element name
		# using the parent_ns_context to resolve namespace references
		def serialize(obj, prefix, name, parent_ns_context = {})
		
			# Create a new element node
			element = LibXML::XML::Node.new(name)
			
			# The namespace context is a simple hash that maps namespace prefixes (String) to
			# LibXML::XML::Namespace instances. 
			ns_context = create_ns_context(element, obj.class, parent_ns_context)
			# Assign the right namespace to the newly created node
			element.namespaces.namespace = ns_context[prefix]
			puts("#{element.name} -> #{element.namespaces.namespace}")
			
			if (obj.class.kind_of?(XmlSerializable))
				obj.class.each_property() do |meta|
					case meta[:xml_type]
					
						when :text
							# text properties become the inner text of the current XML element
							element << serialize_basic_type(get_target_object(obj, meta))
						when :attribute
							# attribute properties become attributes of the current XML element
							element << LibXML::XML::Attr.new(element, meta[:name], serialize_basic_type(get_target_object(obj, meta)), ns_context[meta[:prefix]])
						when :element
							# element properties bocome child elements
							element << serialize(get_target_object(obj, meta), meta[:prefix], meta[:name], ns_context)
						when :array
							
							# If the 'inner_name' attribute is present, then the element name refers to the container
							# element that should contain the array elements, otherwise the array elements will simply
							# be appended to the current element and the 'name' attribute refers to the acutal array
							# element name.
							if (meta[:inner_name] == nil)
								array_element = element
							else
								array_element = LibXML::XML::Node.new(meta[:name])
								array_element.namespaces.namespace = ns_context[meta[:prefix]]
								element << array_element
							end
							
							# Get the prefix and name for the array elements
							inner_name = meta[:inner_name] == nil ? meta[:name] : meta[:inner_name]
							inner_prefix = meta[:inner_name] == nil ? meta[:prefix] : meta[:inner_prefix]
							
							array = get_target_object(obj, meta)
							if (array != nil)
								array.each do |item|
									array_element << serialize(item, inner_prefix, inner_name, ns_context)
								end
							end
						else
							raise("Unknown XML meta property type #{meta[:xml_type]}")
					end
				end
			else
				# Reached "end of the line", a non-XML-serializable value
				element << serialize_basic_type(obj)
			end
			
			return element
		end
		
		# Deserializes the given element to the specified type
		def deserialize(element, type, parent_ns_context = {})
		
			if (type.kind_of?(XmlSerializable))
			
				# If the type is XML-serializable, create a new instance
				obj = type.new()
				
				# The namespace context is a simple hash that maps namespace prefixes (String) to
				# LibXML::XML::Namespace instances. 
				ns_context = create_ns_context(element, obj.class, parent_ns_context)
				
				obj.class.each_property() do |meta|
					case meta[:xml_type]
						when :text
							# deserialize text property
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], element.content))
						when :attribute
							# deserialize attribute property
							attr = element.attributes.get_attribute_ns(ns_context[meta[:prefix]], meta[:name])
							obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], attr))
						when :element
							# deserialize element property
							child = get_child_element(element, ns_context[meta[:prefix]], meta[:name])
							obj.instance_variable_set(meta[:attribute], deserialize(child, meta[:type], ns_context))
						when :array
							# deserialize array property
							array = []
							container = meta[:inner_name] == nil ? element : get_child_element(element, ns_context[meta[:prefix]], meta[:name])
							
							# Get the prefix and name for the array elements
							inner_name = meta[:inner_name] == nil ? meta[:name] : meta[:inner_name]
							inner_prefix = meta[:inner_name] == nil ? meta[:prefix] : meta[:inner_prefix]
							
							each_child_element(element, ns_context[inner_prefix], inner_name) do |child|
								array << deserialize(child, meta[:type], ns_context)
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

		def get_target_object(obj, meta)
			child_obj = obj.instance_variable_get(meta[:attribute])
			
			# Make sure that required properties have non-nil values (all access to instance variables come through here)
			if (meta[:is_required] && child_obj == nil)
				raise(RequiredPropertyException, "#{meta[:name]} is a required attribute for #{obj.class} and may not be nil")
			end
			
			return child_obj
		end
		
		def create_ns_context(element, obj_class, parent_ns_context)
			ns_context = parent_ns_context.clone
			
			if (!ns_context.has_key?(nil))
				ns_context[nil] = ""
			end
			
			if (obj_class.kind_of?(XmlSerializable))
				obj_class.each_namespace() do |ns_prefix, ns_name|
					namespace = LibXML::XML::Namespace.new(element, ns_prefix, ns_name.uri)
					ns_context[ns_prefix] = namespace
				end
			end
			
			return ns_context
		end
		
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
		
		def get_child_element(element, namespace, name)
			element.each_element() do |node|
				if (node.name == name && node.namespaces.namespace == namespace)
					return node
				end
			end
			
			return nil
		end
		
		def each_child_element(element, namespace, name, &block)
			element.each_element() do |node|
				if (node.name == name && node.namespaces.namespace == namespace)
					block.call(node)
				end
			end
		end
		
	end
	
end