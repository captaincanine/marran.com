module Jekyll

   class Site
      
      alias series_site_payload site_payload
      def site_payload
      
         o = series_site_payload
         collections = Hash.new

         self.posts.each do |x|
         
            if x.data.key? 'series'
            
               if !collections.key? x.data['series']['name']
                  collections[x.data['series']['name']] = Array.new
               end
                              
               collections[x.data['series']['name']][x.data['series']['index']] = x
                           
            end
         
         end
         
         collections.each_value { |s| s.compact! }

         o['site']['series'] = collections
                  
         o
         
      end

   end
 
end

