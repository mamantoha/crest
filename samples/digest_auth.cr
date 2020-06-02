require "../src/crest"

request = Crest::Request.new(
  :get,
  "https://httpbin.org/digest-auth/auth/admin/passwd/MD5",
  auth: "digest",
  user: "admin",
  password: "passwd",
  logging: false
)

puts request.to_curl

response = request.execute

puts response.body
puts response.status_code
