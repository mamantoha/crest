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

    def post(payload = {} of String => String, additional_headers = {} of String => String)
      @headers = (@headers || {} of String => String).merge(additional_headers)

      Request.execute(method: :post, url: url, headers: headers, payload: payload)
    end

    def[](suburl)
      self.class.new(concat_urls(url, suburl), headers)
    end

    private def concat_urls(url : String, suburl : String) : String
      if url.byte_slice(-1, 1) == "/" || suburl.byte_slice(0, 1) == "/"
        url + suburl
      else
        "#{url}/#{suburl}"
      end
    end

  end
end
