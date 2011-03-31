
 module Jekyll

	# Extensions to the Jekyll Site class.

	class Site

	  # Add some custom options to the site payload, accessible via the
	  # "site" variable within templates.
	  #
	  # articles - blog articles, in reverse chronological order
	  # max_recent - maximum number of recent articles to display
	  alias orig_site_payload site_payload
	  def site_payload
	  
			h = orig_site_payload
			payload = h["site"]

			latest_blogs = Array.new
			latest_recipes = Array.new

			articles = self.posts.sort {|p1, p2| p2.date <=> p1.date}
			articles.each do |x|
							
				if (x.categories[0] == 'travel' and !payload.key? 'latest_travel')
					payload['latest_travel'] = x
				end
				
				if (x.categories[0] == 'blog' and latest_blogs.length < 5)
					latest_blogs.push x
				end
				
				if (x.categories[0] == 'recipes' and latest_recipes.length < 5)
					latest_recipes.push x
				end
								
			end
			
			payload['latest_blogs'] = latest_blogs
			payload['latest_recipes'] = latest_recipes
															
			h["site"] = payload
			h
	  end

	end
 
 end
 
module PrettyDate
def to_pretty
a = (Time.now-self).to_i

case a
  when 0 then return 'just now'
  when 1 then return 'a second ago'
  when 2..59 then return a.to_s+' seconds ago' 
  when 60..119 then return 'a minute ago' #120 = 2 minutes
  when 120..3540 then return (a/60).to_i.to_s+' minutes ago'
  when 3541..7100 then return 'an hour ago' # 3600 = 1 hour
  when 7101..82800 then return ((a+99)/3600).to_i.to_s+' hours ago' 
  when 82801..172000 then return 'a day ago' # 86400 = 1 day
  when 172001..518400 then return ((a+800)/(60*60*24)).to_i.to_s+' days ago'
  when 518400..1036800 then return 'a week ago'
end
return ((a+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
end
end

Time.send :include, PrettyDate