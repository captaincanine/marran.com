module Jekyll

	class Site

		attr_accessor :ingredients, :dishes

		def reset
			self.ingredients = Hash.new { |hash, key| hash[key] = [] }
			self.dishes = Hash.new { |hash, key| hash[key] = [] }
			self.tags = Hash.new { |hash, key| hash[key] = [] }
		end
		
		alias_method :site_payload_recipe, :site_payload
		def site_payload
			p = site_payload_recipe
			p['site']['ingredients'] = post_attr_hash('ingredients')
			p['site']['dishes'] = post_attr_hash('dishes')
			p
		end

		alias_method :read_posts_recipe, :read_posts
		def read_posts(dir)
		
			read_posts_recipe dir
			self.posts.each do |p| 

				p.tags |= p.ingredients | p.dishes
				
				p.ingredients.each { |pt| self.tags[pt] << p }
				p.dishes.each { |pt| self.tags[pt] << p }

			end
		
		end

	end
	
	class Post
	
		attr_accessor :ingredients, :dishes
		
		alias_method :initialize_recipe, :initialize
		def initialize(site, source, dir, name)
			initialize_recipe site, source, dir, name
			self.ingredients 	= self.data.pluralized_array("ingredient", "ingredients")
			self.dishes 		= self.data.pluralized_array("dish", "dishes")
		end

	end

  module Filters
  
    require 'active_support/all'
  
    # Outputs a list of tags as comma-separated <a> links. This is used
    # to output the tag list for each post on a tag page.
    #
    #  +tags+ is the list of tags to format.
    #
    # Returns string
    def browse_list(tags)
      
      html = String.new
      tags.keys.sort.each do |key|
        tag = key['name'] || key
        html << '<a href="/tags/' + tag.parameterize + '/" class="tag-link">'+tag+'</a>'
      end
      
      "#{html}"
      
    end
    
  end

end