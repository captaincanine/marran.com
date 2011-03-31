module Jekyll

  module Filters
	
    def time_ago(date)
      "<script>document.write($.timeago(\"#{date.strftime('%m-%d-%y')}\"))</script>"
    end
		
		def format_youtube(url)
			matches = url.scan /(?:v=|embed\/)([^&]*)/
			if matches[0] 
				"<iframe title=\"YouTube video player\" width=\"480\" height=\"390\" src=\"http://www.youtube.com/embed/#{matches[0]}\" frameborder=\"0\" allowfullscreen></iframe>"
			end
		end
		
		def format_photo(url)
			"<div class=\"post-image\"><a href=\"#{url}\" rel=\"shadowbox\"><img src=\"#{url}\" /></a></div>"
		end
		
		def format_main_image(p)
			url = p['fullsize'] ? p['fullsize'] : p
		end
	
		def format_teaser_image(p)			
			url = p['thumbnail'] ? p['thumbnail'] : p
		end
      
      def next_in_series(siteseries, info)

			n = siteseries[info['name']].find { |x| x.data['series']['index'] > info['index'] }
			
			if n
				output = "<div class=\"next-box\">"
				output << "<div class=\"help\">This post is part of a series called...</div>"
				output << "<div class=\"series-title\">#{info['name']}</div>"
				output << "<div class=\"help\">The next in the series is...</div>"
				output << "<div class=\"series-item\">"
				output << "<div class=\"title\"><a href=\"#{n.url}\">#{n.data['title']}</a></div>"
				output << "<div class=\"info\">#{n.data['description']}</div>"
				output << "<div class=\"next-link\"><a href=\"#{n.url}\">Read the next post in the series >></a></div>"
				output << "</div>"
				output << "</div>"
				
			end

      end
	
	end

end