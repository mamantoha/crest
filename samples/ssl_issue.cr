require "../src/crest"

tls = OpenSSL::SSL::Context::Client.insecure

# HTTP::Client
uri = URI.parse("https://expired.badssl.com")
client = HTTP::Client.new(uri, tls: tls)
client.get("/")

# Crest
Crest.get("https://expired.badssl.com", tls: tls)

# Crest::Request
request = Crest::Request.new(:get, "https://expired.badssl.com", tls: tls)
request.execute

# Crest::Resource
site = Crest::Resource.new("https://expired.badssl.com", tls: tls)
site.get("/")

# Crest with redirect
url = "http://booking.uz.gov.ua/en/train_search/station/?term=Ter"
request = Crest::Request.new(:get, url, logging: true, tls: tls, handle_errors: false)
response = request.execute
puts response.status_code
