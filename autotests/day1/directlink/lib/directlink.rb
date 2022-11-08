require "fastimage"
require "faraday_middleware"

module DirectLink
  class ErrorBadLink < RuntimeError ; end

  def self.imgur link
    case link
    when /\Ahttps?:\/\/imgur\.com\/([a-zA-Z0-9]+)\z/
      f = FastImage.new "#{link}.png"
      ["#{link}.png", *f.size, f.type]
    else
      raise ErrorBadLink.new link
    end
  end

  def self.reddit link
    case link
    when /\Ahttps?:\/\/.*reddit\.com\/.*/
      connection = Faraday.new("#{link}.json") do |c|
        c.use(FaradayMiddleware::FollowRedirects, limit: 10)
        c.adapter(Faraday.default_adapter)
      end
      response = connection.get
      json = JSON.parse(response.body)
      raise ErrorBadLink.new link unless json.first.include? 'data'

      get_reddit_image_params(json)
    else
      raise ErrorBadLink.new link
    end
  end

  private

  def self.get_reddit_image_params(json)
    source_data = json.first['data']['children'].first['data']['preview']['images'].first['source']
    image_url = source_data['url'].split('?').first  
    image_width = source_data['width']
    image_height = source_data['height']
    image_format = image_url.scan(/\w+\z/).first
    [image_url, image_width, image_height, image_format.to_sym]
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
