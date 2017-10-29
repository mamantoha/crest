require "http"
require "../src/http/proxy"

proxy_host = "localhost"
proxy_port = 3128

username = "user"
password = "qwerty"

proxy = HTTP::Proxy::Client.new(proxy_host, proxy_port, username: username, password: password)
url = "https://httpbin.org"
uri = URI.parse(url)
client = HTTP::Client.new(uri)
client.set_proxy(proxy)
response = client.get("https://httpbin.org/get")

puts "Response status: #{response.try &.status_code}"
puts "Response status: #{response.try &.body}"
