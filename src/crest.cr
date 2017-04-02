require "http"
require "uri"
require "./crest/**"

module Crest

  def self.get(url : String, headers = {} of String => String)
    Request.execute(method: :get, url: url, headers: headers)
  end

  def self.post(url : String, headers = {} of String => String, payload = {} of String => String)
    Request.execute(method: :post, url: url, headers: headers, payload: payload)
  end

end
