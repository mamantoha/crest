require "http"
require "uri"
require "./crest/**"

module Crest
  alias TextValue = String | Symbol | Int32 | Nil

  def self.get(url : String, headers = {} of String => String, params = {} of String => String)
    Request.execute(method: :get, url: url, headers: headers, params: params)
  end

  def self.post(url : String, payload = {} of String => String, headers = {} of String => String, params = {} of String => String)
    Request.execute(method: :post, url: url, headers: headers, payload: payload, params: params)
  end
end
