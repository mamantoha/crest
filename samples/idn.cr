require "../src/crest"
require "uri"

url = "http://кц.рф/"

response = Crest.get(url, logging: true)
puts response.status_code
