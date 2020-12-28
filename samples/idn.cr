require "../src/crest"
require "uri"

url = "http://bücher.ch"

response = Crest.get(url, logging: true)
puts response.status_code
