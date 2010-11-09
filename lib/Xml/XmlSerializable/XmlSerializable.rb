
require("Xml/XmlSerializable/XmlName")

module XmlSerializable
	
	class << self
		def extended(cls)
			super(cls)
			cls.initialize_xml_serializable()
		end
	end
	
	protected

	def xml_element_name(namespace_prefix, name)
		@metadata[:xml_name] = {:prefix => namespace_prefix, :name => name}
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
	
	def xml_array(attribute, prefix, name, type, inner_name = nil, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		xml_array_extended(attribute, prefix, name, type, nil, inner_name, is_required)
	end
	
	def xml_array_extended(attribute, namespace_prefix, name, type, inner_prefix, inner_name, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :array, :attribute => attribute, :prefix => namespace_prefix, :name => name, :type => type, :is_required => is_required, :inner_prefix => inner_prefix, :inner_name => inner_name }
	end
	
	def xml_array_polymorph(attribute, type, is_required=true)
		raise("Each class can either have element type properties or a text type property, not both") if has_text_attribute?()
		@metadata[:xml] << { :xml_type => :array, :attribute => attribute, :prefix => nil, :name => nil, :type => type, :is_required => is_required }
	end
	
	public
	
	def initialize_xml_serializable(parent_class = nil)
		self.instance_eval do
			if (parent_class == nil)
				@metadata = {
					:xml => [], 
					:namespaces => {}, 
					:xml_name => {:prefix => nil, :name => self.to_s().split("::").last || ""}, 
					:subclasses => []
				}
			else
				@metadata = {
					:xml => parent_class.get_xml_metadata().clone(), 
					:namespaces => parent_class.get_namespaces().clone(), 
					:xml_name => {:prefix => nil, :name => self.to_s().split("::").last || ""}, 
					:subclasses => []
				}
			end
			
			def inherited(sub_class)
				@metadata[:subclasses] << sub_class
				sub_class.initialize_xml_serializable(self)
			end
		end
	end
	
	def each_attribute(&block)
		@metadata[:xml].each do |meta|
			block.call(meta) if meta[:xml_type] == :attribute
		end
	end
	
	def each_element(&block)
		@metadata[:xml].each do |meta|
			block.call(meta) if meta[:xml_type] == :element
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
	
	def get_name()
		return @metadata[:xml_name]
	end
	
	def get_namespaces()
		return @metadata[:namespaces]
	end
	
	def get_xml_metadata()
		@metadata[:xml]
	end
	
	def get_subclasses()
		all = @metadata[:subclasses]
		@metadata[:subclasses].each() do |sub|
			all = all + sub.get_subclasses()
		end
		return all
	end
	
	def print_metadata()
		p @metadata
	end
	
end