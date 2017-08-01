require "http"
require "uri"
require "./crest/**"

module Crest
  alias TextValue = String | Symbol | Int32 | Nil

  {% for method in %w{get delete} %}
    def self.{{method.id}}(url : String, headers = {} of String => String, params = {} of String => String)
      Request.execute(method: :{{method.id}}, url: url, headers: headers, params: params)
    end
  {% end %}

  {% for method in %w{post put patch} %}
    def self.{{method.id}}(url : String, payload = {} of String => String, headers = {} of String => String, params = {} of String => String)
      Request.execute(method: :{{method.id}}, url: url, headers: headers, payload: payload, params: params)
    end
  {% end %}
end
