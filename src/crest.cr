require "http"
require "uri"
require "base64"
require "./crest/**"
require "./http/proxy/client"

module Crest
  alias TextValue = String | Symbol | Int32 | Nil

  {% for method in %w{get delete post put patch} %}
    def self.{{method.id}}(url : String, **args)
      Request.execute(:{{method.id}}, url, **args)
    end
  {% end %}
end
