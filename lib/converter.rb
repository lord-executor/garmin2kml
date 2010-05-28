require("rexml/document")
require("Kml/Document")
require("Kml/Placemark")
require("Kml/LineString")
require("Kml/Point")
require("Kml/CoordinateTuple")
require("Kml/Style")
require("Kml/IconStyle")
require("Kml/LineStyle")
require("Kml/Icon")
require("Kml/HsvColor")

include REXML

Radius = 6371 # mean earth radius in km

if (ARGV.length < 3) then
	puts("Usage: <program> <filename> <trackname> <description>")
	Process.exit()
end

def gpx2kml(gpxPoint)
	Kml::CoordinateTuple.new(gpxPoint.attributes["lon"], gpxPoint.attributes["lat"], gpxPoint.elements["ele"].text)
end

def distance(gpxPoint1, gpxPoint2)
	
	return 0 unless gpxPoint1 != nil && gpxPoint2 != nil
	
	lat1 = gpxPoint1.attributes["lat"].to_f() / 180.0 * Math::PI
	lat2 = gpxPoint2.attributes["lat"].to_f() / 180.0 * Math::PI
	lon1 = gpxPoint1.attributes["lon"].to_f() / 180.0 * Math::PI
	lon2 = gpxPoint2.attributes["lon"].to_f() / 180.0 * Math::PI
	
	dLat = lat2 - lat1
	dLon = lon2 - lon1
	
	a = Math::sin(dLat/2) ** 2 + Math::cos(lat1) * Math::cos(lat2) * Math::sin(dLon/2) ** 2
	c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
	return Radius * c
end

inputFile = ARGV[0]
input = Document.new(File.new(inputFile))

kmlDoc = Kml::Document.new()
kmlDoc.name = ARGV[1]
kmlDoc.description = ARGV[2]

# Add starting point
startPoint = input.get_elements("//trkpt")[0]
startMark = Kml::Placemark.new()
startMark.name = "Start"
startMark.description = startPoint.elements["time"].text
startMark.geometry = Kml::Point.new()
startMark.geometry.position = gpx2kml(startPoint)
kmlDoc.add_feature(startMark)

input.each_element("/gpx/trk/trkseg") do |trackSegment|
	if (trackSegment.elements.size < 2) then
		trackSegment.parent.delete_element(trackSegment)
	end
end

segmentCount = input.get_elements("/gpx/trk/trkseg").length
currentSegment = 1
totalDistance = 0
lastPoint = nil

input.each_element("/gpx/trk/trkseg") do |trackSegment|

	segment = Kml::Placemark.new()
	segment.name = "Segment #{currentSegment}"
	segment.geometry = Kml::LineString.new()
	
	style = Kml::Style.new("segment#{currentSegment}")
	style.lineStyle = Kml::LineStyle.new()
	style.lineStyle.width = 5.0
	style.lineStyle.color = Kml::HsvColor.new((currentSegment - 1.0)/segmentCount, 1.0, 1.0, 0.5).to_abgr_hex()
	segment.add_style(style)
	segment.styleUrl = "#segment#{currentSegment}"
	
	segmentDistance = 0

	trackSegment.each_element("trkpt") do |trackPoint|
		dist = distance(lastPoint, trackPoint)
		segmentDistance += dist
		totalDistance += dist
		
		segment.geometry.add_tuple(gpx2kml(trackPoint))
		
		lastPoint = trackPoint
	end
	
	startTime = trackSegment.get_elements("trkpt")[0].elements["time"].text
	endTime = trackSegment.get_elements("trkpt")[-1].elements["time"].text
	segment.description = "#{startTime} - #{endTime}<br />#{segmentDistance} km"
	kmlDoc.add_feature(segment)
	
	currentSegment += 1
end

# Add end point
endPoint = input.get_elements("//trkpt")[-1]
endMark = Kml::Placemark.new()
endMark.name = "End"
endMark.description = "#{endPoint.elements["time"].text}<br />Total distance: #{totalDistance} km"
endMark.geometry = Kml::Point.new()
endMark.geometry.position = gpx2kml(endPoint)
kmlDoc.add_feature(endMark)

kmlDoc.xmlDoc.write($stdout, 1, true)

Process.exit

