module Crest
  class Request

    @method : String
    @url : String
    @headers : HTTP::Headers
    @payload : String? = nil

    getter method, url, payload, headers

    def self.execute(method, url, **args)
      new(method, url, **args).execute
    end

    # Crest::Request.execute(method: :post, url: "http://example.com/user?name=Kurt", payload: {:age => "27"})
    # Mandatory parameters:
    # * :method
    # * :url
    # Optional parameters:
    # * :headers a hash containing the request headers
    # * :payload a hash containing query params
    #
    def initialize(method : Symbol, url : String, headers = {} of String => String, payload = {} of String => String, **args)
      @method = parse_verb(method)
      @url = url

      @headers = read_headers(headers)

      unless payload.empty?
        @payload, content_type = Payload.generate(payload)
        @headers.add("Content-Type", content_type)
      end
    end

    def execute() : HTTP::Client::Response
      HTTP::Client.exec(method, url, body: payload, headers: headers)
    end

    private def parse_verb(method : String | Symbol) : String
      method.to_s.upcase
    end

    private def read_headers(params) : HTTP::Headers
      headers = HTTP::Headers.new

      params.each do |key, value|
        headers.add(key, value)
      end

      headers
    end
  end

end
