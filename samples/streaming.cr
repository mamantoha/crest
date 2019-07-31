require "../src/crest"
require "json"

response = Crest::Request.get("http://httpbin.org/stream/5") do |resp|
  puts resp.status_code # => 200
  resp.body_io.each_line do |line|
    puts JSON.parse(line)
  end
end
response # => nil

resource = Crest::Resource.new("http://httpbin.org")
resource["/stream/5"].get do |resp|
  puts resp.status_code # => 200
  resp.body_io.each_line do |line|
    puts JSON.parse(line)
  end
end

Crest.get("https://github.com/mamantoha/crest/archive/v0.17.0.zip") do |resp|
  filename = resp.filename || "crest.zip"

  File.open(filename, "w") do |file|
    IO.copy(resp.body_io, file)
  end
end
