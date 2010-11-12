
current_dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << current_dir

#require("StringIO")
require("Gpx/Root")
require("Kml/Root")
require("Util/HsvColor")
require("Xml/XmlSerializable/Serializer")

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

class Accumulator
	
	# mean earth radius in kilometers
	RADIUS = 6371
	
	attr_reader(:segment_count,
				:segment_distance, :segment_elevation_up, :segment_elevation_down,
				:total_distance, :total_elevation_up, :total_elevation_down)
	
	def initialize()
		reset()
	end
	
	def reset()
		@segment_count = 0
		@segment_distance = 0
		@segment_elevation_up = 0
		@segment_elevation_down = 0
		@total_distance = 0
		@total_elevation_up = 0
		@total_elevation_down = 0
	end
	
	def reset_segment()
		@segment_count = @segment_count + 1
		@segment_distance = 0
		@segment_elevation_up = 0
		@segment_elevation_down = 0
	end
	
	def add_point(gpx_point)
		if (@last_point != nil)
			d = distance(@last_point, gpx_point)
			h = gpx_point.elevation - @last_point.elevation
			
			@segment_distance += d
			@segment_elevation_up += (h > 0 ? h : 0)
			@segment_elevation_down -= (h < 0 ? h : 0)
			@total_distance += d
			@total_elevation_up += (h > 0 ? h : 0)
			@total_elevation_down -= (h < 0 ? h : 0)
		end
		
		@last_point = gpx_point
	end
	
	def get_segment_stats()
		stats = StringIO.new()
		stats << "Distance: #{@segment_distance} km<br />\n"
		stats << "Elevation: +#{@segment_elevation_up} m / -#{@segment_elevation_down} m<br />\n"
		return stats.string
	end
	
	def get_total_stats()
		stats = StringIO.new()
		stats << "Distance: #{@total_distance} km<br />\n"
		stats << "Elevation: +#{@total_elevation_up} m / -#{@total_elevation_down} m<br />\n"
		return stats.string
	end
	
	private
	
	def distance(point1, point2)
		lat1 = point1.latitude.to_f() / 180.0 * Math::PI
		lat2 = point2.latitude.to_f() / 180.0 * Math::PI
		lon1 = point1.longitude.to_f() / 180.0 * Math::PI
		lon2 = point2.longitude.to_f() / 180.0 * Math::PI
		
		delta_lat = lat2 - lat1
		delta_lon = lon2 - lon1
		
		a = Math::sin(delta_lat/2) ** 2 + Math::cos(lat1) * Math::cos(lat2) * Math::sin(delta_lon/2) ** 2
		c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
		return RADIUS * c
	end
	
end

class Converter

	def convert(gpx_root)
		@accumulator = Accumulator.new()
		kml_document = Kml::Document.new()
		
		gpx_root.tracks.each do |track|
			process_track(kml_document, track)
		end
		
		kml_root = Kml::Root.new()
		kml_root.document = kml_document
		return kml_root
	end
	
	def create_point_mark(gpx_point, name, description)
		point = Kml::Point.new()
		point.position = gpx2kml(gpx_point)
		
		placemark = Kml::Placemark.new()
		placemark.name = name
		placemark.description = description
		placemark.geometry = [point]
		
		return placemark
	end
	
	def process_track(kml_document, gpx_track)
		start_point = gpx_track.segments.first.points.first
		kml_document.features << create_point_mark(start_point, "Start", start_point.time)
		
		@segment_count = gpx_track.segments.size
		gpx_track.segments.each do |track_segment|
			process_track_segment(kml_document, track_segment)
		end
		
		end_point = gpx_track.segments.last.points.last
		kml_document.features << create_point_mark(end_point, "End", "#{end_point.time}<br />\n#{@accumulator.get_total_stats()}")
	end
	
	def process_track_segment(kml_document, gpx_track_segment)
		line_string = Kml::LineString.new()
		
		segment_id = @accumulator.segment_count
		
		style = Kml::Style.new()
		style.id = "segment#{segment_id}"
		style.line_style = Kml::LineStyle.new()
		style.line_style.width = 5.0
		style.line_style.color = Garmin2Kml::Util::HsvColor.new(segment_id.to_f()/@segment_count, 1.0, 1.0, 0.5).to_abgr_hex()
		
		@accumulator.reset_segment()
		gpx_track_segment.points.each do |point|
			@accumulator.add_point(point)
			#line_string.add_tuple(gpx2kml(point))
		end
		
		segment = Kml::Placemark.new()
		segment.name = "Segment #{segment_id}"
		segment.description = @accumulator.get_segment_stats()
		segment.style_url = style.id
		segment.styles = [style]
		segment.geometry = [line_string]
		kml_document.features << segment
	end
	
	def gpx2kml(gpx_point)
		Kml::CoordinateTuple.new(gpx_point.longitude, gpx_point.latitude, gpx_point.elevation)
	end
	
end

serializer = XmlSerializable::Serializer.new()

gpx_doc = LibXML::XML::Document.file(ARGV[0])
gpx_root = serializer.from_document(gpx_doc,Gpx::Root)

converter = Converter.new()
kml_root = converter.convert(gpx_root)
kml_root.document.name = ARGV[1]
kml_root.document.description = ARGV[2]

result = serializer.create_document(kml_root, nil, "kml")
puts(result)

exit(0)

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
	style.lineStyle.color = Garmin2Kml::Util::HsvColor.new((currentSegment - 1.0)/segmentCount, 1.0, 1.0, 0.5).to_abgr_hex()
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

#kmlDoc.xmlDoc.write($stdout, 1, true)
formatter = Xml::Formatters::Reasonable.new()
formatter.write(kmlDoc.xmlDoc, $stdout)

Process.exit

