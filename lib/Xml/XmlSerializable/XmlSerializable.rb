
require("rexml/document")
require("Xml/XmlSerializable/Serializer")

module XmlSerializable
	
	class << self
		def extended(cls)
			super(cls)
			
			cls.instance_eval do
				@metadata = {:xml => []}
			end
		end
	end
	
	def xml_attribute(attribute, name, type, is_required=true)
		@metadata[:xml] << { :xml_type => :attribute, :attribute => attribute, :name => name, :type => type, :is_required => is_required }
	end
	
	def xml_element(attribute, name, type, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :element, :attribute => attribute, :name => name, :type => type, :is_required => is_required }
	end
	
	def xml_text(attribute)
		raise("Each class can only have one text type property") if has_text_attribute?()
		raise("Each class can either have element type properties or a text type property, not both") if has_element_attribute?()
		@metadata[:xml] << { :xml_type => :text, :attribute => attribute, :type => String,  :is_required => true }
	end
	
	def xml_array(attribute, name, type, inner_name = nil, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :array, :attribute => attribute, :name => name, :type => type, :is_required => is_required, :inner_name => inner_name }
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
	
	def print_metadata()
		p @metadata
	end
	
end