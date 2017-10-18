require "../src/crest"

url = "http://httpbin.org/get"
payload = {:fizz => "buz"}
res = Crest.get(url, headers: {"Access-Token" => ["secret1", "secret2"]}, params: payload)

puts "# Header"
puts res.headers

puts "# Body"
puts res.body

puts "# Code"
puts res.status_code

puts "# HTTP client response"
puts res.http_client_res

puts "# HTTP request"
puts res.request
