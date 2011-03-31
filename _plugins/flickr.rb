module Jekyll

	require 'flickraw'
	require 'ruby-debug'
	
  class GeneratePhotosets < Generator

		safe true
		priority :low

		def generate(site)
			generate_photosets(site) if (site.config['flickr']) 
		end
		
		def generate_photosets(site)
			site.posts.each do |p|
			  p.data['photos'] = load_photos(p.data['photoset'], site) if p.data['photoset']
			end
		end

		def load_photos(photoset, site)

      if cache_dir = site.config['flickr_cache']
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
		
			FlickRaw.api_key = site.config['flickr_api_key']
			FlickRaw.shared_secret = site.config['flickr_shared_secret']
			
			auth = flickr.auth.checkToken :auth_token => site.config['flickr_auth_token']
			
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