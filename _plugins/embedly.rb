require 'rubygems'
require 'net/https'
require 'uri'
require 'json'
require 'domainatrix'

module Jekyll
  class Embedly < Liquid::Tag
    @@EMBEDLY_PARAMETERS = ['maxwidth', 'maxheight', 'format', 'callback',
                            'wmode', 'allowscripts', 'nostyle', 'autoplay',
                            'videosrc', 'words', 'chars', 'width', 'height']

    def initialize(tag_name, text, tokens)
      super

      tokens      = text.split /\,\s/
      @url        = tokens[0]
      @parameters = {}

      tokens[1..-1].each do |arg|
        key, value = arg.split /:/
        value ||= "1"
        @parameters[key.strip] = value.strip
      end
    end

    def render(context)
      @config  = context.registers[:site].config['embedly']
      @api_key = @config['api_key']

      if @api_key.nil?
        raise "You must provide embed.ly api key."
      end

      embed @url
    end

    private

    def embed(url)
      provider     = Domainatrix.parse(url).domain
      param_string = ""
      params       = (@config[provider] or {}).merge @parameters

      params.each do |key, value|
        if @@EMBEDLY_PARAMETERS.member? key
          value = CGI::escape value.to_s
          param_string << "&#{key}=#{value}"
        else
          url << (url.match(/\?/) ? "&" : "?") << "#{key}=#{value}"
        end
      end

      encoded_url = CGI::escape url
      embedly_url = URI.parse "http://api.embed.ly/1/oembed?key=#{@api_key}" +
                              "&url=#{encoded_url}#{param_string}"

      json_rep = JSON.parse resolve(embedly_url)

      compose json_rep
    end

    def compose(json_rep)
      type     = json_rep['type']
      provider = json_rep['provider_name'].downcase

      if type == 'photo'
        url    = json_rep['url']
        width  = json_rep['width']
        height = json_rep['height']
        desc   = CGI::escapeHTML json_rep['description']
        html   = "<img src=\"#{url}\" alt=\"#{desc}\" width=\"#{width}\" height=\"#{height}\" />"
      else
        html = json_rep['html']
      end

      "<div class=\"embed #{type} #{provider}\">#{html}</div>"
    end

    def resolve(uri)
      response = Net::HTTP.get_response(uri)

      unless response['location'].nil? and response['Location'].nil?
        resolve URI.parse(response['location']) or
                URI.parse(response['Location'])
      else
        response.body
      end
    end
  end
end

Liquid::Template.register_tag('embedly', Jekyll::Embedly)