
require("libxml")
require("XmlSerializable/RequiredPropertyException")

module XmlSerializable
	
	class Serializer
		
		# Creates an XML document from the given object using root_namespace_prefix and
		# root_element_name as NS prefix and element name for the root XML node.
		# Note that the prefix for the root element has to match an XML namespace definition
		# in obj's class definition.
		def create_document(obj, root_namespace_prefix, root_element_name)
			doc = LibXML::XML::Document.new()
			doc.root = create_element(obj, root_namespace_prefix, root_element_name)
			return doc
		end
		
		# Creates an XML node form the given object
		def create_element(obj, prefix, name)
			return serialize(obj, prefix, name)
		end
		
		# Creates an object of the given type from the provided XML element
		def from_element(element, type)
			return deserialize(element, type)
		end
		
		# Creates an object of the given type from the provided XML document
		def from_document(document, type)
			return deserialize(document.root, type)
		end
		
		# Serializes the given object as an XML element with the provided namespace prefix and element name
		# using the parent_ns_context to resolve namespace references
		def serialize(obj, prefix, name, parent_ns_context = {})
		
			prefix, name = get_name_and_prefix(obj, prefix, name)
			# Create a new element node
			element = LibXML::XML::Node.new(name)
			
			# The namespace context is a simple hash that maps namespace prefixes (String) to
			# LibXML::XML::Namespace instances. 
			ns_context = create_ns_context(element, obj.class, parent_ns_context)
			# Assign the right namespace to the newly created node
			element.namespaces.namespace = ns_context[prefix] unless ns_context[prefix] == nil
			
			if (obj.class.kind_of?(XmlSerializable))
				obj.class.each_property() do |meta|
				
					target_obj = get_target_object(obj, meta)
					case meta[:xml_type]
					
						when :text
							# text properties become the inner text of the current XML element
							element << serialize_basic_type(target_obj)
						when :attribute
							# attribute properties become attributes of the current XML element
							if (target_obj != nil)
								LibXML::XML::Attr.new(element, meta[:name], serialize_basic_type(target_obj), ns_context[meta[:prefix]])
							end
						when :element
							# element properties bocome child elements
							if (target_obj != nil)
								element << serialize(target_obj, meta[:prefix], meta[:name], ns_context)
							end
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
							
							array = target_obj
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
		def deserialize(element, type, parent_ns_context = {}, allow_derived = false)
			
			if (type.kind_of?(XmlSerializable))
			
				if (allow_derived)
					type = get_derived_type(element, type, parent_ns_context)
				end
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
							if (meta[:prefix] == nil)
								attr = element.attributes.get_attribute(meta[:name])
							else
								attr = element.attributes.get_attribute_ns(ns_context[meta[:prefix]].href, meta[:name])
							end
							
							if (meta[:is_required] && attr == nil)
								raise(RequiredPropertyException, "#{meta[:name]} is a required attribute for #{obj.class} and may not be missing")
							elsif (attr != nil)
								obj.instance_variable_set(meta[:attribute], deserialize_basic_type(meta[:type], attr == nil ? nil : attr.value))
							end
						when :element
							# deserialize element property
							child = get_child_element(element, ns_context, meta[:type], meta[:prefix], meta[:name])
							
							if (meta[:is_required] && child == nil)
								raise(RequiredPropertyException, "#{meta[:name]} is a required attribute for #{obj.class} and may not be missing")
							elsif (child != nil)
								obj.instance_variable_set(meta[:attribute], deserialize(child, meta[:type], ns_context))
							end
						when :array
							# deserialize array property
							array = []
							container = meta[:inner_name] == nil ? element : get_child_element(element, ns_context, meta[:type], meta[:prefix], meta[:name])
							
							if (meta[:is_required] && container == nil)
								raise(RequiredPropertyException, "#{meta[:name]} is a required attribute for #{obj.class} and may not be missing")
							elsif (container != nil)
								# Get the prefix and name for the array elements
								inner_name = meta[:inner_name] == nil ? meta[:name] : meta[:inner_name]
								inner_prefix = meta[:inner_name] == nil ? meta[:prefix] : meta[:inner_prefix]
								
								each_child_element(element, ns_context[inner_prefix], inner_name) do |child|
									array << deserialize(child, meta[:type], ns_context, inner_name == nil)
								end
								
								obj.instance_variable_set(meta[:attribute], array)
							end
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
		
		def get_name_and_prefix(obj, prefix, name)
			if (name == nil)
				if (obj.class.kind_of?(XmlSerializable))
					xml_name = obj.class.get_name()
					return [xml_name[:prefix], xml_name[:name]]
				else
					raise("No element name provided and object type #{obj.class} is not XmlSerializable")
				end
			else
				return [prefix, name]
			end
		end
		
		def get_derived_type(node, type, parent_ns_context)
			candidates = [type] + type.get_subclasses()
			candidates.each() do |candidate|
				xml_name = candidate.get_name()
				ns_context = create_ns_context(node, candidate, parent_ns_context)
				if (node.namespaces.namespace == ns_context[xml_name[:prefix]] && node.name == xml_name[:name])
					return candidate
				end
			end
		end

		def get_target_object(obj, meta)
			child_obj = obj.instance_variable_get(meta[:attribute])
			
			# Make sure that required properties have non-nil values (all access to instance variables come through here)
			if (meta[:is_required] && child_obj == nil)
				raise(RequiredPropertyException, "#{meta[:attribute]} is a required attribute for #{obj.class} and may not be nil")
			end
			
			return child_obj
		end
		
		def create_ns_context(element, obj_class, parent_ns_context)
			ns_context = parent_ns_context.clone
			
			if (obj_class.kind_of?(XmlSerializable))
				obj_class.each_namespace() do |ns_prefix, ns_name|
					namespace = element.namespaces.find_by_href(ns_name.uri)
					if (namespace == nil)
						namespace = LibXML::XML::Namespace.new(element, ns_prefix, ns_name.uri)
					end
					ns_context[ns_prefix] = namespace
				end
			end
			
			return ns_context
		end
		
		def serialize_basic_type(obj)
			if (obj == nil)
				return ""
			end
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
		
		def get_child_element(element, ns_context, type, prefix, name)
			element.each_element() do |node|
				child_context = create_ns_context(node, type, ns_context)
				if (node.name == name && node.namespaces.namespace.href == child_context[prefix].href)
					return node
				end
			end
			
			return nil
		end
		
		def each_child_element(element, namespace, name, &block)
			element.each_element() do |node|
				if (name == nil || (node.name == name && node.namespaces.namespace == namespace))
					block.call(node)
				end
			end
		end
		
	end
	
end