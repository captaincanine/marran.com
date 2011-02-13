require 'rubygems'
require 'fgraph'
require 'fileutils'
require 'json'
require 'ruby-debug'
require 'net/ftp'

module Jekyll
  module Facebook

    def self.process()

		app_id = '185393810259'
		app_secret = '32e4b648ac7dce75457e194ec7a09c85'
		callback_url = 'http://www.marran.com/sites/all/modules/fbconnect/xd_receiver.html'

		auth_code = '535894bb6e37ac8caa11defc-790499637|WCYmAxPN1RDHE5us3OPCpKxFSmc'

		token = FGraph.oauth_access_token(app_id, app_secret, :redirect_uri => callback_url, :code => auth_code )
				
		File.open("/Volumes/Repositively/pelosi/Sites/marran-jekyll/js/facebook/feed.js", "w") do |f|
			data = FGraph.me_feed(:access_token => token['access_token'])
			f.puts data.to_json
      end

		ftp = Net::FTP.new('ftp.marran.com')
		ftp.login 'pelosi', 'trial5'
		ftp.chdir('/httpdocs/js/facebook')
		ftp.puttextfile('/Volumes/Repositively/pelosi/Sites/marran-jekyll/js/facebook/feed.js', 'feed.js')
		ftp.close

    end

  end
end