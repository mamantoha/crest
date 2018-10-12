require "../crest"

tls = OpenSSL::SSL::Context::Client.insecure

# HTTP::Client
uri = URI.parse("https://expired.badssl.com")
client = HTTP::Client.new(uri, tls: tls)
response = client.get("/")

# Crest
response = Crest.get("https://expired.badssl.com", tls: tls)

# Crest::Request
request = Crest::Request.new(:get, "https://expired.badssl.com", tls: tls)
response = request.execute

# Crest::Resource
site = Crest::Resource.new("https://expired.badssl.com", tls: tls)
response = site.get("/")
