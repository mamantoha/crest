require "../src/crest"

proxy_host = "localhost"
proxy_port = 3128
username = "user"
password = "qwerty"

response = Crest.get("https://httpbin.org/get", p_addr: proxy_host, p_port: proxy_port, p_user: username, p_pass: password)
puts "Response status: #{response.try &.status_code}"
puts "Response status: #{response.try &.body}"
