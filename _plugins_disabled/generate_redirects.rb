module Jekyll
  
  # The TagIndex class creates a single tag page for the specified tag.
  class RedirectPage < Page
    
    # Initializes a new TagIndex.
    #
    #  +base+         is the String path to the <source>.
    #  +tag_dir+ is the String path between <source> and the tag folder.
    #  +tag+     is the tag currently being processed.
    def initialize(site, base, path, destination)
    
		@site = site
		@base = base
		@dir  = path
		@name = 'index.html'
		self.process(@name)
		
		# Read the YAML data from the layout page.
		self.read_yaml(File.join(base, '_layouts'), 'redirect.html')
		self.data['refresh_to_post_id']    = destination
      
    end
    
  end

  # Jekyll hook - the generate method is called by jekyll, and generates all of the redirect pages.
  class GenerateRedirects < Generator
  
		safe true
		priority :low

		def generate(site)
			generate_redirects(site) if (site.config['redirects']) 		
		end

		def generate_redirects(site)

			site.posts.select{|x| x.data.key? 'redirects' }.each do |p|
				p.data['redirects'].each do |r|	
					redirect = RedirectPage.new(site, site.source, r, p.id)
					redirect.render(site.layouts, site.site_payload)
					redirect.write(site.dest)
					site.pages << redirect			
				end			
			end
			
		end

  end
  
end