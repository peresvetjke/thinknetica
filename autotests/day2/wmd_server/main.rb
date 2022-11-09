# require "pp"

require "sinatra"
# set :dump_errors, false

# require "filemagic"
require "tempfile"
require "yaml/store"

cache = YAML::Store.new "cache.yaml"
semaphore = Mutex.new
get /.*/ do
  # unless request.env["REQUEST_PATH"] == request.env["PATH_INFO"]
  #   pp request
  #   abort
  # end
  path = "websites/automationpractice.com/#{request.path[1..-1]}#{"?#{request.query_string}" unless request.query_string.empty?}"
  begin
    case path
    when /\.css\z/
      send_file path, type: "text/css"
    when /\.js\z/
      send_file path, type: "text/javascript"
    else
      # case mime = semaphore.synchronize{ cache.transaction{ cache[path] ||= FileMagic.mime.file path } }
      case mime = semaphore.synchronize{ cache.transaction{ cache[path] ||= "text/plain" } }
      when /\Atext\/html;/
        file = Tempfile.new "temp", tmpdir: "temp"
        file.write File.read(path).gsub "http://automationpractice.com/", ""
        send_file file.path, disposition: :inline, type: mime
      else
        send_file path, type: mime
      end
    end
  rescue
    abort "#{$!} #{$!.inspect}"
  end
end

# # test that all files are served with no issues
# Thread.abort_on_exception = true
# Thread.new do
#   require "open-uri"
#   begin
#     open "http://localhost:4567/index.php", &:read
#   rescue Errno::ECONNREFUSED
#     retry
#   rescue OpenURI::HTTPError
#   rescue
#     abort "#{$!} #{$!.inspect}"
#   end
#   Dir.glob "websites/automationpractice.com/**" do |path|
#     next if File.directory? path
#     begin
#       p open("http://localhost:4567/#{path[32..-1]}", &:read).size
#     rescue
#       abort "#{$!} #{$!.inspect}"
#     end.size
#   end
#   puts "OK"
# end
