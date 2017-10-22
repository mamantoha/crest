require "../src/crest"

url = "http://httpbin.org/cookies"
res = Crest.get(url, cookies: {"v1" => "k1"})
puts "Body:"
puts res.body
puts "Headers:"
puts res.headers
puts "Cookies:"
puts res.cookies

params = {"k1" => "v1", "k2" => "v2"}
url = "http://httpbin.org/cookies/set"
res = Crest.get(url, params: params)
puts "Body:"
puts res.body
puts "Headers:"
puts res.headers
puts "Cookies:"
puts res.cookies

url = "http://httpbin.org/headers"
res = Crest.get(url, headers: {"Authorization" => "Bearer cT0febFoD5lxAlNAXHo6g"})
puts "Body:"
puts res.body
puts "Headers:"
puts res.headers
puts "Cookies:"
puts res.cookies
