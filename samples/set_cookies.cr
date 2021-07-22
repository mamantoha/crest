require "../src/crest"

url = "http://httpbin.org/cookies"
response = Crest.get(url, cookies: {"k1" => "v1", "k2" => {"kk2" => "vv2"}}, logging: true)
puts response.cookies
# => {"k1" => "v1", "k2[kk2]" => "vv2"}

params = {"k1" => "v1", "k2" => "v2"}
url = "http://httpbin.org/cookies/set"
response = Crest.get(url, params: params, logging: true)
puts response.body

url = "http://httpbin.org/headers"
Crest.get(url, headers: {"Authorization" => "Bearer cT0febFoD5lxAlNAXHo6g"}, logging: true)
