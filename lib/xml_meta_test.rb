
current_dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << current_dir

require("Xml/Formatters/Reasonable")
require("Xml/XmlSerializable/XmlSerializable")

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
serializer = XmlSerializable::Serializer.new()
node = serializer.serialize(me, "person")
formatter = Xml::Formatters::Reasonable.new()
formatter.write(node, $stdout)
puts()
puts("-------------")
copy = serializer.deserialize(node, Person)
puts("Other Person = #{copy.inspect}")
