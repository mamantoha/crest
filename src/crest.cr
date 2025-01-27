require "json"
require "http"
require "uri"
require "base64"
require "http-client-digest_auth"
require "http_proxy"
require "./ext/io"
require "./ext/http/cookie"

# This module's static methods are the entry point for using the Crest client.
#
# Supported HTTP methods: `get`, `put`, `post`, `patch` `delete`, `options`, `head`
#
# Examples:
#
# ```
# Crest.get(
#   "http://httpbin.org/get",
#   headers: {"Content-Type" => "image/jpg"},
#   params: {"lang" => "en"}
# )
#
# Crest.post(
#   "http://httpbin.org/post",
#   headers: {"Access-Token" => ["secret1", "secret2"]},
#   form: {"fizz" => "buz"},
#   logging: true,
# )
#
# Crest.get("http://httpbin.org/stream/5") do |response|
#   while line = response.body_io.gets
#     puts line
#   end
# end
# ```
module Crest
  VERSION    = {{ `shards version #{__DIR__}`.chomp.stringify }}
  USER_AGENT = "Crest/#{Crest::VERSION} (Crystal/#{Crystal::VERSION})"

  alias ParamsValue = Bool | Float32 | Float64 | Int32 | Int64 | String | Symbol | Nil | IO?

  HTTP_METHODS = %w{get delete post put patch options head}

  {% for method in Crest::HTTP_METHODS %}
    # Execute a {{method.id.upcase}} request and and yields the `Crest::Response` to the block.
    #
    # ```
    # Crest.{{method.id}}("http://httpbin.org/{{method.id}}") do |response|
    #   while line = response.body_io.gets
    #     puts line
    #   end
    # end
    # ```
    def self.{{method.id}}(url : String, form = {} of String => String, **args, &block : Crest::Response ->) : Nil
      request = Request.new(:{{method.id}}, url, form, **args)
      request.execute(&block)
    end

    # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
    #
    # ```
    # Crest.{{method.id}}("http://httpbin.org/{{method.id}}")
    # ```
    def self.{{method.id}}(url : String, form = {} of String => String, **args) : Crest::Response
      request = Request.new(:{{method.id}}, url, form, **args)
      request.execute
    end
  {% end %}
end

require "./crest/**"
