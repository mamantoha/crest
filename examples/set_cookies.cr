require "../src/crest"

params = {"k1" => "v1", "k2" => "v2"}
url = "http://httpbin.org/cookies/set"
res = Crest.get(url, params: params)
puts res.http_client_res.cookies.inspect
