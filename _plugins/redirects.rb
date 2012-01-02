module Jekyll

  # The redirect page creates a simple page that refreshes a user from a URL alias to an existing post.
  # Redirects are only generated if there is a "redirects" parameter _config.yml
  
  class Redirects < Generator
    
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

  class RedirectPage < Page
    
    def initialize(site, base, path, destination)
    
      @site = site
      @base = base
      @dir  = path
      @name = 'index.html'
      self.process(@name)
      
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'redirect.html')
      self.data['source_url'] = destination
      
    end
    
  end
  
end