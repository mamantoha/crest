require "../src/crest"

params = {"k1" => "v1", "k2" => "v2"}
url = "http://httpbin.org/cookies/set"
res = Crest.get(url, params: params)
puts "Body:"
puts res.body
puts "Headers:"
puts res.headers
puts "Cookies:"
puts res.request_cookies
