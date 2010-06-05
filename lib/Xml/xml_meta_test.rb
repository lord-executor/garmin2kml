
require("rexml/document")

module XmlSerializable
	
	class << self
		def extended(cls)
			super(cls)
			puts "#{cls} extended #{self}"
			
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
	
	class XmlSerializer
		
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

class Contact
	extend(XmlSerializable)
	
	attr_accessor(:skype, :email)
	
	xml_element(:@skype, "skype", String)
	xml_element(:@email, "email", String)
end

class Job
	extend(XmlSerializable)
	
	attr_accessor(:description, :from, :until)
	
	xml_attribute(:@from, "from", Integer)
	xml_attribute(:@until, "until", Integer)
	xml_text(:@description)
end

class Person
	extend(XmlSerializable)
	
	attr_accessor(:name, :contact, :aliases, :jobs)
	
	xml_attribute(:@name, "name", String)
	xml_element(:@contact, "contact", Contact)
	xml_array(:@aliases, "alias", String)
	xml_array(:@jobs, "jobs", Job, "job")
end


require("rexml/formatters/transitive")

puts()
puts("Starting test")
puts("-------------")
puts("Person:")
Person.print_metadata()
puts("Contact:")
Contact.print_metadata()
puts("Job:")
Job.print_metadata()
puts("-------------")
me = Person.new()
me.name = "Anakin Skywalker"
me.aliases = [ "Lord Vader", "Darth Vader", "Luke's Dad" ]
me.contact = Contact.new()
me.contact.skype = "darth.vader"
me.contact.email = "lord.vader@hotmail.com"
job1 = Job.new()
job1.from = 1977
job1.until = 1983
job1.description = "Lacky of emperor Palpatine"
job2 = Job.new()
job2.from = 1983
job2.until = 1999
job2.description = "Dead Jedi"
job3 = Job.new()
job3.from = 1999
job3.until = 2002
job3.description = "Young padawan in training"
me.jobs = [job1, job2, job3]
puts("Person = #{me.inspect}")
puts("-------------")
serializer = XmlSerializable::XmlSerializer.new()
node = serializer.serialize(me, "person")
formatter = REXML::Formatters::Pretty.new()
formatter.write(node, $stdout)
puts()
puts("-------------")
copy = serializer.deserialize(node, Person)
puts("Other Person = #{copy.inspect}")
