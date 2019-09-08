require "../src/crest"

response = Crest.get("https://httpbin.org/digest-auth/auth/admin/passwd/MD5", auth: "digest", user: "admin", password: "passwd")

puts response.body
puts response.status_code
