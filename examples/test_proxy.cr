require "../src/crest"

proxy_host = "localhost"
proxy_port = 3128
username = "user"
password = "qwerty"

response = Crest.get("http://httpbin.org/get", p_addr: "localhost", p_port: 3128, p_user: "user", p_pass: "qwerty")
puts "Response status: #{response.try &.status_code}"
puts "Response status: #{response.try &.body}"
