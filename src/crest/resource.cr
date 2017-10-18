module Crest
  class Resource
    getter url, headers, params

    def initialize(url : String, headers = {} of String => String, params = {} of String => String, **args)
      @url = url
      @headers = headers
      @params = params
    end

    {% for method in %w{get delete} %}
      def {{method.id}}(additional_headers = {} of String => String, params = {} of String => String)
        @headers = (@headers || {} of String => String).merge(additional_headers)

        Request.execute(method: :{{method.id}}, url: url, headers: headers, params: params)
      end
    {% end %}

    {% for method in %w{post put patch} %}
      def {{method.id}}(payload = {} of String => String, additional_headers = {} of String => String, params = {} of String => String)
        @headers = (@headers || {} of String => String).merge(additional_headers)

        Request.execute(method: :{{method.id}}, url: url, headers: headers, payload: payload, params: params)
      end
    {% end %}

    def [](suburl)
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
