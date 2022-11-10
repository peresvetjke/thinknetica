# frozen_string_literal: true

require "fastimage"
require "faraday_middleware"
require "json"

module DirectLink
  class ErrorBadLink < RuntimeError; end

  class << self
    def imgur link
      case link
      when /\Ahttps?:\/\/imgur\.com\/([a-zA-Z0-9]+)\z/
        f = FastImage.new "#{link}.png"
        ["#{link}.png", *f.size, f.type]
      else
        raise ErrorBadLink.new link
      end
    end

    def reddit link
      case link
      when /\Ahttps?:\/\/.*reddit\.com\/.*/
        connection = Faraday.new("#{link}.json") do |c|
          c.use(FaradayMiddleware::FollowRedirects, limit: 10)
          c.adapter(Faraday.default_adapter)
        end
        response = connection.get
        json = JSON.parse(response.body)
        raise ErrorBadLink.new link if reddit_image_params(json).any?(&:nil?)
        
        reddit_image_params(json)
      else
        raise ErrorBadLink.new link
      end
    end

    private

    def reddit_image_params(json)
      image_url = json.dig(0, 'data', 'children', 0, 'data', 'url_overridden_by_dest')
      image_width = json.dig(0, 'data', 'children', 0, 'data', 'preview', 'images', 0, 'source', 'width')
      image_height = json.dig(0, 'data', 'children', 0, 'data', 'preview', 'images', 0, 'source', 'height')
      image_format = image_url&.scan(/\w+\z/)&.first
      [image_url, image_width, image_height, image_format&.to_sym]
    end
  end
end

def DirectLink link
  raise ::DirectLink::ErrorBadLink.new link unless host = URI(link).host
  case host.split(?.).last(2)
  when %w{ imgur com }
    ::DirectLink.imgur link
  when %w{ reddit com }
    ::DirectLink.reddit link
  else
    raise ::DirectLink::ErrorBadLink.new link
  end
end
