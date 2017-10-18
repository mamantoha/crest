module Crest
  class Request
    @method : String
    @url : String
    @headers : HTTP::Headers
    @payload : String? = nil
    @max_redirects : Int32

    getter method, url, payload, headers, max_redirects

    def self.execute(method, url, **args)
      new(method, url, **args).execute
    end

    # Crest::Request.execute(method: :post, url: "http://example.com/user", payload: {:age => 27}, params: {:name => "Kurt"})
    #
    # Mandatory parameters:
    # * :method
    # * :url
    # Optional parameters:
    # * :headers a hash containing the request headers
    # * :payload a hash containing query params
    # * :params a hash that represent query-string separated from the preceding part by a question mark (?)
    #          a sequence of attribute–value pairs separated by a delimiter (&).
    # * :max_redirects maximum number of redirections (default to 10)
    #
    def initialize(method : Symbol, url : String, headers = {} of String => String, payload = {} of String => String, params = {} of String => String, **args)
      @method = parse_verb(method)
      @url = url

      @max_redirects = args.fetch(:max_redirects, 10)

      unless params.empty?
        @url = url + process_url_params(params)
      end

      @headers = read_headers(headers)

      unless payload.empty?
        @payload, content_type = Payload.generate(payload)
        @headers.add("Content-Type", content_type)
      end
    end

    def execute : Crest::Response
      response = HTTP::Client.exec(method, url, body: payload, headers: headers)
      process_result(response)
    end

    private def process_result(http_client_res)
      response = Response.create(http_client_res, self)
      response.return!
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
