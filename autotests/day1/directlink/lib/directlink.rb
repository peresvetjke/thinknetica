require "fastimage"

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

  # def self.reddit link
  # end

end

def DirectLink link
  raise ::DirectLink::ErrorBadLink.new link unless host = URI(link).host
  case host.split(?.).last(2)
  when %w{ imgur com }
    ::DirectLink.imgur link
  else
    raise ::DirectLink::ErrorBadLink.new link
  end
end
