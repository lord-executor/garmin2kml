
require("Garmin2Kml/Accumulator")
require("Gpx/Root")
require("Kml/Root")
require("Garmin2Kml/Util/HsvColor")

module Garmin2Kml
	
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
				line_string.add_tuple(gpx2kml(point))
			end
			
			segment = Kml::Placemark.new()
			segment.name = "Segment #{segment_id}"
			segment.description = @accumulator.get_segment_stats()
			segment.style_url = "##{style.id}"
			segment.styles = [style]
			segment.geometry = [line_string]
			kml_document.features << segment
		end
		
		def gpx2kml(gpx_point)
			Kml::CoordinateTuple.new(gpx_point.longitude, gpx_point.latitude, gpx_point.elevation)
		end
		
	end
	
end
