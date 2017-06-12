module Crest
  class Resource

    getter url, headers

    def initialize(url : String, headers = {} of String => String)
      @url = url
      @headers = headers
    end

    def get(additional_headers = {} of String => String)
      @headers = (@headers || {} of String => String).merge(additional_headers)

      Request.execute(method: :get, url: url, headers: headers)
    end
  end
end
