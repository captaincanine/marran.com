require 'rubygems'
require 'sequel'
require 'fileutils'
require 'yaml'
require 'ruby-debug'
require 'flickraw'

# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

module Jekyll
  module Drupal

    # Reads a MySQL database via Sequel and creates a post file for each
    # post in wp_posts that has post_status = 'publish'.
    # This restriction is made because 'draft' posts are not guaranteed to
    # have valid dates.

    def self.process(dbname, user, pass, host = 'localhost')

      db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')

      # Create the refresh layout
      # Change the refresh url if you customized your permalink config
      # Add url_alias support
      File.open("_layouts/refresh.html", "w") do |f|
        f.puts <<EOF
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<meta http-equiv="refresh" content="0;url={{ page.refresh_to_post_id }}" />
</head>
</html>
EOF
      end

		book_query = "SELECT parent.nid as 'parent_nid', parent.title as 'parent_title', child.nid as 'child_nid', child.title as 'child_title' FROM node as parent inner join book on parent.nid = book.bid inner join node as child on child.nid = book.nid"
		books = db[book_query]

		node_query = "SELECT node.nid, node.type, node.title, node_revisions.body, node_revisions.teaser, node.created, node.status, (select dst from url_alias where src = CONCAT('node/', node.nid)) as 'path_alias', (select field_teaser_image_url from content_field_teaser_image where nid = node.nid and vid = node.vid) as 'image' FROM node, node_revisions WHERE node.type in ('blog', 'story') AND node.vid = node_revisions.vid"
      db[node_query].each do |post|

			terms_query = "select tn.nid, td.tid, td.name, (select tp.name from term_hierarchy inner join term_data tp on tp.tid = term_hierarchy.parent where td.tid = term_hierarchy.tid) as parent from term_data td inner join term_node tn on td.tid = tn.tid where tn.nid = #{post[:nid]}"
			terms = db[terms_query]

			convert = DrupalConverter.new(post, terms, books)
			
			# Write out the data and content to file
			FileUtils.mkdir_p "#{convert.dir}/#{convert.category}"
			File.open("#{convert.dir}/#{convert.category}/#{convert.name}", "w") do |f|
				f.puts convert.data
				f.puts "---"
				f.puts convert.content
			end
			
			# Make a file to redirect from the old Drupal URL
=begin
			if convert.published?

				FileUtils.mkdir_p "node/#{convert.nid}"
				File.open("node/#{convert.nid}/index.textile", "w") do |f|
					f.puts "---"
					f.puts "layout: refresh"
					f.puts "refresh_to_post_id: /#{convert.slug}"
					f.puts "---"
				end

				FileUtils.mkdir_p "#{convert.path_alias}"
				File.open("#{convert.path_alias}/index.textile", "w") do |f|
					f.puts "---"
					f.puts "layout: refresh"
					f.puts "refresh_to_post_id: /#{convert.slug}"
					f.puts "---"
				end

			end
=end
		end

    end
    
    
    
    class DrupalConverter
    
    	attr_accessor	:category, :images, :photoset, :dish, :ingredients, :series, :tags, :redirects

    	def initialize(post, terms, books)

			@post = post
			@terms = terms
			@books = books
			
			@category = 'blog'
			@images = Array.new
			@body = post[:body]
			
			@redirects = ["/node/#{post[:nid]}", "/#{post[:path_alias]}"]
			
			process_tags
			process_series
			
			parse_photoset
			parse_images
			
			parse_videos

			convert_main_image

		end
		
		def path_alias
			@post[:path_alias]
		end
		
		def dir
			"_posts"
		end
		
		def nid
			@post[:nid]
		end
		
		def slug
			@post[:title].strip.downcase.gsub(/(&|&amp;)/, ' and ').gsub(/[\s\.\/\\]/, '-').gsub(/[^\w-]/, '').gsub(/[-_]{2,}/, '-').gsub(/^[-_]/, '').gsub(/[-_]$/, '')
		end
		
		def name
        time.strftime("%Y-%m-%d-") + self.slug + '.textile'
		end
		
		def published?
			@post[:status] == 1
		end
		
		def process_series
		
			@books.each_with_index do |b, i|
				@series = { 'name' => b[:parent_title].to_s, 'index' => i } if b[:child_nid] == @post[:nid]			
			end
		
		end
		
		def data
			{
           'layout' => self.layout,
           'title' => self.title,
           'description' => self.description,
           'images' => self.images,
           'tags' => self.tags,
           'photoset' => self.photoset,
           'dish' => self.dish,
           'ingredients' => self.ingredients,
           'series' => self.series,
           'redirects' => self.redirects
         }.delete_if { |k,v| v.nil? || v == ''}.to_yaml
		end
		
		def images
			@images.uniq if @images.size != 0
		end
		
		def ingredients
			@ingredients if @ingredients.size != 0
		end
		
		def tags
			@tags if @tags.size != 0
		end
		
		def content
			@body			
		end
		
		def time
			Time.at(@post[:created])
		end
		
		def layout
			@post[:path_alias]['personal/recipes'] == 'personal/recipes' ? 'recipe' : 'post'
		end
		
		def title
			@post[:title].to_s
		end
		
		def description
			@post[:teaser].to_s.gsub(/<\/?[^>]*>/, "").gsub(/\n/, "").strip
		end
		
		def process_tags

			@tags = Array.new
			@ingredients = Array.new

			@terms.each do |t|			
			
				if t[:parent] == 'dish'
					@dish = t[:name]
					@category = 'recipe'
				elsif t[:parent] == 'ingredient'
					@ingredients.push t[:name]
					@category = 'recipe'
				elsif t[:parent] == 'travel'
					@category = 'travel'
					@tags.push t[:name]
				else
					@tags.push t[:name]
				end

			end
			
			@tags.uniq!
			@tags.compact!

			@ingredients.uniq!
			@ingredients.compact!
		 
		end
		
		def parse_photoset
		
			match = @body.match('\[flickr-photoset:id=(\w+)\]')
			if match
				@photoset = match[1].to_i
			end

			@body = @body.gsub /\[flickr-photoset:id=(\w+)\]/, '<!-- \0 -->'
		
		end
		
		def parse_images
		
			match = @body.match('\[flickr-photo:id=(\w+)\]')
			if match
				
				photo = Hash.new
				new_url = get_flickr_url(match[1].to_i, photo)

				begin

					@images.push photo
					@body = @body.gsub /\[flickr-photo:id=(\w+)\]/, '{{ "' + photo['fullsize'] + '" | format_photo }}'

				rescue
					puts "Having trouble here for some reason: #{@post[:title]}"					
				end


			end
		
		end
						
		def parse_videos
		
			match = @body.match('\[video:http:\/\/www.youtube.com\/watch\?v=(\S+)\]')
			if match
			
				youtube_id = match[1]
				new_url = "http://www.youtube.com/embed/#{youtube_id}"
				
				@images.push "http://img.youtube.com/vi/#{youtube_id}/0.jpg"
				
				@body = @body.gsub /\[video:http:\/\/www.youtube.com\/watch\?v=(\S+)\]/, '{{ "' + new_url + '" | format_youtube }}'

			end
		
		end
		
		def convert_main_image
		
			original_url = String.new
		
			#see if there is an image specified in the database and look for the larger version
			if @post[:image]
							
				match = @post[:image].to_s.match('\/([0-9]*)_')
				if match
					photo = Hash.new
					@images.push get_flickr_url(match[1].to_i, photo)
				end
			
			end
		
		end
		
		def get_flickr_url(photo_id, h)
				
			FlickRaw.api_key = 'd5873a8ac7aca2b68cd2c5314daa9890'
			FlickRaw.shared_secret = 'adca51085c67435b'
			
			auth = flickr.auth.checkToken :auth_token => '72157625809066009-b86580f891a5e8e9'
			
			begin

				sizes = flickr.photos.getSizes(:photo_id => photo_id).to_a.map { |x| x.to_hash }
				
				h['fullsize'] = sizes[sizes.rindex{|x|x['width'].to_i < 1200}]['source']
				h['thumbnail'] = sizes[sizes.rindex{|x|x['label'].to_s == 'Small'}]['source']

			rescue
				p "Can't find image for #{photo_id} in #{@post[:title]}" 
			end
			
			h
		
		end

	end
    
  end
end
