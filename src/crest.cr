require "http"
require "uri"
require "base64"
require "./http/proxy/client"

# This module's static methods are the entry point for using the Crest client.
#
# Suported HTTP methods: `get`, `put`, `post`, `patch` `delete`, `options`
#
# Examples:
#
# ```crystal
# Crest.get(
#   "http://example.com/resource",
#   headers: {"Content-Type" => "image/jpg"},
#   params: {"lang" => "en"}
# )
#
# Crest.post(
#   "http://httpbin.org/post",
#   headers: {"Access-Token" => ["secret1", "secret2"]},
#   form: {:fizz => "buz"},
#   logging: true,
# )
#
# Crest.get("http://example.com/resource") do |request|
#   request.headers.add("Content-Type", "image/jpg")
# end
# ```
module Crest
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  alias TextValue = String | Symbol | Int32 | Nil

  alias Params = Hash(Symbol | String, Int32 | String) |
                 Hash(String, String | Int32) |
                 Hash(Symbol, String | Int32) |
                 Hash(String, String) |
                 Hash(String, Int32) |
                 Hash(Symbol, String) |
                 Hash(Symbol, Int32)

  HTTP_METHODS = %w{get delete post put patch options}

  {% for method in Crest::HTTP_METHODS %}
    # Execute a {{method.id.upcase}} request and and yields the `Crest::Request` to the block.
    #
    # ```crystal
    # Crest.{{method.id}}("http://www.example.com") do |request|
    #   request.headers.add("Content-Type", "application/json")
    # end
    # ```
    def self.{{method.id}}(url : String, **args) : Crest::Response
      request = Request.new(:{{method.id}}, url, **args)

      yield request

      exec(request)
    end

    # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
    #
    # ```crystal
    # Crest.{{method.id}}("http://www.example.com")
    # ```
    def self.{{method.id}}(url : String, **args) : Crest::Response
      {{method.id}}(url, **args) { }
    end

  {% end %}

  # Executes a `request`.
  private def self.exec(request : Crest::Request) : Crest::Response
    request.execute
  end
end

require "./crest/**"
