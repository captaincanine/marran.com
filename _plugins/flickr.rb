=begin

This module enables easy integration to Flickr for showing photos. In
posts, if there is a "photoset" attribute in the post, Jekyll will get
the photo information from Flickr and add it to the post data.

Since the Flickr calls can be very time-consuming, the calls to Flickr
are cached.

In order to use this, you need to have previously authorized with
Flickr. The following information needs to be in _config.yml:

flickr:
  enabled:         yes
  cache_dir:       ./_cache/flickr
  api_key:         {{ your flickr api key }}
  shared_secret:   {{ your flickr shared secret }}
  auth_token:      {{ your flickr auth token }}

=end

require 'flickraw'

module Jekyll
	
  class GeneratePhotosets < Generator

		safe true
		priority :low

		def generate(site)
			generate_photosets(site) if (site.config['flickr']['enabled']) 
		end
		
		def generate_photosets(site)
			site.posts.each do |p|
			  p.data['photos'] = load_photos(p.data['photoset'], site) if p.data['photoset']
			end
		end

		def load_photos(photoset, site)

      if cache_dir = site.config['flickr']['cache_dir']
        path = File.join(cache_dir, "#{Digest::MD5.hexdigest(photoset.to_s)}.yml")
        if File.exist?(path)
          photos = YAML::load(File.read(path))
        else
          photos = generate_photo_data(photoset, site)
          File.open(path, 'w') {|f| f.print(YAML::dump(photos)) }
        end
      else
        photos = generate_photo_data(photoset, site)
      end
  
      photos
  
    end

    def generate_photo_data(photoset, site)
			
			returnSet = Array.new 
		
			FlickRaw.api_key = site.config['flickr']['api_key']
			FlickRaw.shared_secret = site.config['flickr']['shared_secret']
			
			auth = flickr.auth.checkToken :auth_token => site.config['flickr']['auth_token']
			
			photos = flickr.photosets.getPhotos :photoset_id => photoset
			
			photos.photo.each_index do | i |
			
				title = photos.photo[i].title
				id = photos.photo[i].id
				fullSizeUrl = String.new
				urlThumb = String.new
				urlFull = String.new
				thumbType = String.new
					
				sizes = flickr.photos.getSizes(:photo_id => id).to_a
				sizes.each do | s |
				
					if s.width.to_i < 1200
						urlFull = s.source
					end
					
					if s.label == 'Small' && i < 3
						urlThumb = s.source
						thumbType = 'thumbnail'
					end
					
					if s.label == 'Square' && i >= 3
						urlThumb = s.source
						thumbType = 'square'
					end
				
				end
	
				photo = FlickrPhoto.new(title, urlFull, urlThumb, thumbType)
				returnSet.push photo
			
			end
			
			#sleep a little so that you don't get in trouble for bombarding the Flickr servers
			sleep 1
			
			returnSet
	
		end
	
  end
  
	class FlickrPhoto

		attr_accessor :title, :urlFullSize, :urlThumbnail, :thumbType
		
		def initialize(title, urlFullSize, urlThumbnail, thumbType)
			@title = title
			@urlFullSize = urlFullSize
			@urlThumbnail = urlThumbnail
			@thumbType = thumbType
		end
		
		def to_liquid
			{
				'title' => title,
				'urlFullSize' => urlFullSize,
				'urlThumbnail' => urlThumbnail,
				'thumbType' => thumbType
			}
      
		end

	end

end