=begin

CategoryPagination allows jekyll sites to have index pages for each category, and to break those 
category indexes into multiple pages.

This code belongs in the _plugins directory. 

The following items need to be true:

*   There is a file called "category_index.html" in the _layouts directory
*   In the _config.yml, there needs to be a line that says "pagination: true"
*   There needs to be an "index.html" page with "category: category-name" in the YAML front matter. 
    Be sure to use the actual category name.
    
For instance, if you wanted to have a paginated set of pages for all posts in the "recipes" 
category, place a file called "index.html" in the "recipes" directory. Make sure that in the 
YAML front matter, there is a line that says "category: recipes".

This plugin is structured so that each category index page can have its own unique landing page. 
For instance, a page showing all the recipes can be different than the page showing all the blog
entries. Subsequent pages (page 2 of the recipes, for example), use the category_index.html 
template. This is by design. Perhaps someday I'll add a parameter to the index page to specify
which template to use for sub-pages.

I have created a custom filter for displaying previous and next links on category pages.

=end

module Jekyll

  class CategoryPagination < Generator
  
    safe true

    def generate(site)
      site.pages.dup.each do |page|
        paginate(site, page) if CategoryPager.pagination_enabled?(site.config, page)
      end
    end

    def paginate(site, page)
    
      all_posts = site.categories[page.data['category']].sort_by { |p| p.date }
      all_posts.reverse!

      pages = CategoryPager.calculate_pages(all_posts, site.config['paginate'].to_i)

      (1..pages).each do |num_page|
        pager = CategoryPager.new(site.config, num_page, all_posts, page.data['category'], pages)
        if num_page > 1
          newpage = CategorySubPage.new(site, site.source, "_layouts", page.data['category'])
          newpage.pager = pager
          newpage.dir = File.join(page.dir, "/#{page.data['category']}/page#{num_page}")
          site.pages << newpage
        else
          page.pager = pager
        end
      end
    end

  end

  # The CategorySubPage class creates a single category page for the specified tag.
  class CategorySubPage < Page
    
    # Initializes a new CategorySubPage.
    #
    #  +base+         is the String path to the <source>.
    #  +tag_dir+ is the String path between <source> and the tag folder.
    #  +tag+     is the tag currently being processed.
    def initialize(site, base, tag_dir, category)
      @site = site
      @base = base
      @dir  = tag_dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')

      title_prefix             = site.config['cateogry_title_prefix'] || 'Everything in the '
      self.data['title']       = "#{title_prefix}#{category}"

    end
    
  end

  class CategoryPager

    attr_reader :page, :per_page, :posts, :total_posts, :total_pages, :previous_page, :next_page, :category

    def self.calculate_pages(all_posts, per_page)
      num_pages = all_posts.size / per_page.to_i
      num_pages = num_pages + 1 if all_posts.size % per_page.to_i != 0
      num_pages
    end

    def self.pagination_enabled?(config, page)
      page.name == 'index.html' && page.data.key?('category') && !config['paginate'].nil?
    end

    def initialize(config, page, all_posts, category, num_pages = nil)
        
    	@category = category
      @page = page
      @per_page = config['paginate'].to_i
      @total_pages = num_pages || Pager.calculate_pages(all_posts, @per_page)

      if @page > @total_pages
        raise RuntimeError, "page number can't be greater than total pages: #{@page} > #{@total_pages}"
      end

      init = (@page - 1) * @per_page
      offset = (init + @per_page - 1) >= all_posts.size ? all_posts.size : (init + @per_page - 1)

      @total_posts = all_posts.size
      @posts = all_posts[init..offset]
      @previous_page = @page != 1 ? @page - 1 : nil
      @next_page = @page != @total_pages ? @page + 1 : nil

    end

    def to_liquid
      {
        'page' => page,
        'per_page' => per_page,
        'posts' => posts,
        'total_posts' => total_posts,
        'total_pages' => total_pages,
        'previous_page' => previous_page,
        'next_page' => next_page,
        'category' => category
      }
    end
  end
  
  module Filters
  
  	def pager_links(pager)

		if pager['previous_page'] || pager['next_page']
  	  	
			html = '<div class="pager clearfix">'
			if pager['previous_page']
				
				if pager['previous_page'] == 1
					html << "<div class=\"previous\"><a href=\"/#{pager['category']}/\">« Newer posts</a></div>"
				else
					html << "<div class=\"previous\"><a href=\"/#{pager['category']}/page#{pager['previous_page']}\">« Newer posts</a></div>"
				end
	
			end
	
			if pager['next_page'] 
				html << "<div class=\"next\"><a href=\"/#{pager['category']}/page#{pager['next_page']}\">Older posts »</a></div>"
			end
			
			html << '</div>'
			html

		end

  	end
  
  end

end