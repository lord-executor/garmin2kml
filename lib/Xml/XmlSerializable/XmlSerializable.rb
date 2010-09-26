
require("Xml/XmlSerializable/XmlName")

module XmlSerializable
	
	class << self
		def extended(cls)
			super(cls)
			
			cls.instance_eval do
				@metadata = {:xml => [], :namespaces => {}}
			end
		end
	end
	
	def xml_namespace(prefix, namespace_uri)
		xml_name = XmlName.new(prefix, namespace_uri)
		@metadata[:namespaces][xml_name.prefix] = xml_name
	end
	
	def xml_attribute(attribute, namespace_prefix, name, type, is_required=true)
		@metadata[:xml] << { :xml_type => :attribute, :attribute => attribute, :prefix => namespace_prefix, :name => name, :type => type, :is_required => is_required }
	end
	
	def xml_element(attribute, namespace_prefix, name, type, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :element, :attribute => attribute, :prefix => namespace_prefix, :name => name, :type => type, :is_required => is_required }
	end
	
	def xml_text(attribute)
		raise("Each class can only have one text type property") if has_text_attribute?()
		raise("Each class can either have element type properties or a text type property, not both") if has_element_attribute?()
		@metadata[:xml] << { :xml_type => :text, :attribute => attribute, :type => String,  :is_required => true }
	end
	
	def xml_array(attribute, namespace_prefix, name, type, inner_name = nil, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :array, :attribute => attribute, :prefix => namespace_prefix, :name => name, :type => type, :is_required => is_required, :inner_name => inner_name }
	end
	
	def each_attribute(&block)
		@metadata[:xml].each do |meta|
			block.call(meta) if meta[:xml_type] == :attribute
		end
	end
	
	def each_element()
		@metadata[:xml].each do |meta|
			yield(meta) if meta[:xml_type] == :element
		end
	end
	
	def each_property(&block)
		@metadata[:xml].each() { |meta| block.call(meta) }
	end
	
	def get_text_attribute()
		return (@metadata[:xml].select() { |meta| meta[:xml_type] == :text }).first
	end
	
	def has_element_attribute?()
		!(@metadata[:xml].select() { |meta| meta[:xml_type] == :element }).empty?()
	end
	
	def has_text_attribute?()
		!(@metadata[:xml].select() { |meta| meta[:xml_type] == :text }).empty?()
	end
	
	def each_namespace(&block)
		@metadata[:namespaces].each do |key, value|
			block.call(key, value)
		end
	end
	
	def get_namespaces()
		return @metadata[:namespaces]
	end
	
	def get_xml_metadata()
		@metadata[:xml]
	end
	
	def print_metadata()
		p @metadata
	end
	
end