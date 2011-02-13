module Jekyll

	class Post

		def related_posts(posts)
			
			relations = Array.new
			postMatches = Hash.new
			
			posts.each_index do |i|
							
				tagMatches = self.tags & posts[i].tags
				if tagMatches.length > 0
					postMatches[i] = tagMatches.length
				end
			
			end
		
			postMatches.each {|k, p| relations << posts[k] }
		
			(relations - [self])
		
		end

	end

end