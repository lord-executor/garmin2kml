
require("rexml/document")

module Xml
	module Formatters
		
		class Reasonable < REXML::Formatters::Default
			
			def initialize(indentation = 1, indent_string = "\t")
				@indentation = indentation
				@indent_string = indent_string
				@current_indent = 0
			end
			
			def write_element(node, output)
				output << "\n" if @current_indent == 0
				output << "<#{node.expanded_name}"
				
				node.attributes.to_a.sort_by {|attr| attr.name}.each do |attr|
					output << " "
					write_attribute(attr, output)
				end unless node.attributes.empty?
				
				if node.children.empty?
					output << " /"
				else
					has_text = node.children.any? { |c| c.instance_of?(REXML::Text) }
					@current_indent += @indentation
					output << ">"
					node.children.each do |child|
						output << "\n" + @indent_string * @current_indent unless has_text
						write( child, output )
					end
					@current_indent -= @indentation
					output << "\n" + @indent_string * @current_indent unless has_text
					output << "</#{node.expanded_name}"
				end
				output << ">"
				output << "\n" if @current_indent == 0
			end
			
			protected
			
			def write_attribute(node, output)
				output << "#{node.expanded_name}=\"#{node.to_s().gsub(/"/, "&quot;")}\""
			end
			
		end
		
	end
end

#include(Xml::Formatters)
#include(REXML)

## read document removing all whitespace-only text nodes
#doc = Document.new(File.new("sample.xml"), { :ignore_whitespace_nodes => :all })
#formatter = Reasonable.new()
#formatter.write(doc, $stdout)
