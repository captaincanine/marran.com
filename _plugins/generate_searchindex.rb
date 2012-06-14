module Jekyll

  class SearchIndex < Page
    def initialize(site, base, dir, letters)
      @site = site
      @base = base
      @dir = dir
      @name = "#{letters}.json"

      self.process(@name)
    end
  end

  class SearchPost < Page
    def initialize(site, base, dir, pid, post)
      @site = site
      @base = base
      @dir = dir
      @name = "#{pid}.html"

      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'search_post.html')
      # Set the title for this page.
      self.data['title'] = post.data['title']
      self.data['link'] = post.url
      self.data['description'] = post.data['description']
    end
  end
	
	class Site
	
		attr_accessor :search_index, :search_posts
  
		def write_search_files

			createindex!
  	
			dir = self.config['search_dir'] || 'search'
			
			self.search_index.keys.each do |letter|
				write_search_index(self, File.join(dir, 'terms'), letter, self.search_index[letter])
			end
						
			self.search_posts.keys.each do |i|
				write_search_post(self, File.join(dir, 'posts'), i, self.search_posts[i])
			end
  	
		end
  
    def write_search_index(site, dir, letter, data)
    	require 'json'
      index = SearchIndex.new(site, site.source, dir, letter)        			
			index.output = data.to_json
      index.write(site.dest)
      self.static_files << index
    end
    
    def write_search_post(site, dir, pid, post)
      index = SearchPost.new(site, site.source, dir, pid, post)
      index.render(site.layouts, site_payload)
      index.write(site.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.static_files << index
    end
    
    def createindex!
        
      require 'lingua/stemmer'
      stemmer = Lingua::Stemmer.new
      
      searchwords = Hash.new
      postlist = Hash.new
					
      self.posts.each_index do |i|
      
      	rawtext = self.posts[i].to_s.downcase

      	if self.posts[i].data['title']
      		rawtext << ' ' + self.posts[i].data['title'].downcase
      	end
      	
      	if self.posts[i].data['description']
      		rawtext << ' ' + self.posts[i].data['description'].downcase
      	end
			
        rawtext.scan(/[a-zA-Z0-9]{1,}/).each do |word|
			
          postlist[i] = self.posts[i]
        
          word = stemmer.stem(word)
          letter = word[0,2]
          
          if !searchwords.key?(letter)
            searchwords[letter] = Hash.new
          end
          
          if !searchwords[letter].key?(word)
            searchwords[letter][word] = Array.new
          end
          
          searchwords[letter][word].push(i)
          
        end
				
      end

      self.search_index = searchwords
      self.search_posts = postlist

    end
    
  end
  
    
  class SearchGenerator < Generator

		safe true
		priority :low
				
		def generate(site)
			site.write_search_files if (site.config['searchindex']) 
		end
    	
	end

end