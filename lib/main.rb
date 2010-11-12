
current_dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << current_dir

require("Garmin2Kml/Converter")
require("Gpx/Root")
require("Kml/Root")
require("Xml/XmlSerializable/Serializer")

if (ARGV.length < 3) then
	puts("Usage: <program> <filename> <trackname> <description>")
	Process.exit()
end

serializer = XmlSerializable::Serializer.new()

gpx_doc = LibXML::XML::Document.file(ARGV[0])
gpx_root = serializer.from_document(gpx_doc,Gpx::Root)

converter = Garmin2Kml::Converter.new()
kml_root = converter.convert(gpx_root)
kml_root.document.name = ARGV[1]
kml_root.document.description = ARGV[2]

result = serializer.create_document(kml_root, nil, "kml")
puts(result)

exit(0)
