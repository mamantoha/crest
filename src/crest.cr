require "http"
require "uri"
require "base64"
require "./crest/**"
require "./http/proxy/client"

# This module's static methods are the entry point for using the Crest client.
#
# Suported HTTP methods: `get`, `put`, `post`, `patch` `delete`
#
# Examples:
#
# ```
# Crest.get(
#   "http://example.com/resource",
#   headers: {"Content-Type" => "image/jpg"},
#   params: {"lang" => "en"}
# )
#
# Crest.post(
#   "http://httpbin.org/post",
#   headers: {"Access-Token" => ["secret1", "secret2"]},
#   payload: {:fizz => "buz"},
#   logging: true,
# )
# ```
module Crest
  alias TextValue = String | Symbol | Int32 | Nil

  alias Params = Hash(Symbol | String, Int32 | String) |
                 Hash(String, String | Int32) |
                 Hash(Symbol, String | Int32) |
                 Hash(String, String) |
                 Hash(String, Int32) |
                 Hash(Symbol, String) |
                 Hash(Symbol, Int32)

  {% for method in %w{get delete post put patch} %}
    # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
    #
    # ```
    # response = Crest.{{method.id}}("http://www.example.com")
    # ```
    def self.{{method.id}}(url : String, **args)
      Request.execute(:{{method.id}}, url, **args)
    end
  {% end %}
end
