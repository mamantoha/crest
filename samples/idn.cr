require "../src/crest"
require "uri"

url = "http://домен.укр/"

response = Crest.get(url, logging: true)
puts response.status_code
