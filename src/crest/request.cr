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
    # * :params a hash that represent query-string separated from the preceding part by a question mark (?)
    #          a sequence of attribute–value pairs separated by a delimiter (&).
    #
    def initialize(method : Symbol, url : String, headers = {} of String => String, payload = {} of String => String, params = {} of String => String, **args)
      @method = parse_verb(method)
      @url = url

      unless params.empty?
        @url = url + process_url_params(params)
      end

      @headers = read_headers(headers)

      unless payload.empty?
        @payload, content_type = Payload.generate(payload)
        @headers.add("Content-Type", content_type)
      end
    end

    def execute() : HTTP::Client::Response
      # TODO: JSON
      # payload="{\"title\": \"Title\"}"
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

    # Extract the query parameters and append them to the url
    #
    private def process_url_params(url_params) : String
      query_string = Crest::Utils.encode_query_string(url_params)

      if url.includes?("?")
        return "&" + query_string
      else
        return "?" + query_string
      end
    end
  end

end
