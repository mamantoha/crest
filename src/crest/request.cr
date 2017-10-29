module Crest
  class Request
    @method : String
    @url : String
    @headers : HTTP::Headers
    @cookies : HTTP::Cookies
    @payload : String?
    @max_redirects : Int32
    @user : String?
    @password : String?
    @proxy : HTTP::Proxy::Client?
    @p_addr : String?
    @p_port : Int32?
    @p_user : String?
    @p_pass : String?

    getter method, url, payload, headers, cookies, max_redirects, user, password, proxy
    # An array of previous redirection responses
    property redirection_history

    def self.execute(method, url, **args)
      new(method, url, **args).execute
    end

    # Crest::Request.execute(method: :post, url: "http://example.com/user", payload: {:age => 27}, params: {:name => "Kurt"})
    #
    # Mandatory parameters:
    # * method
    # * url
    # Optional parameters:
    # * :headers a hash containing the request headers
    # * :cookies a hash containing the request cookies
    # * :payload a hash containing query params
    # * :params a hash that represent query-string separated from the preceding part by a question mark (?)
    #          a sequence of attribute–value pairs separated by a delimiter (&).
    # * :user and :password for basic auth
    # * :p_addr, :p_port, :p_user, :p_pass for proxy
    # * :max_redirects maximum number of redirections (default to 10)
    #
    def initialize(
                   method : Symbol,
                   url : String,
                   *,
                   headers = {} of String => String,
                   cookies = {} of String => String,
                   payload = {} of String => String,
                   params = {} of String => String,
                   max_redirects = 10,
                   **options)
      @method = parse_verb(method)
      @url = url
      @headers = HTTP::Headers.new
      @cookies = HTTP::Cookies.new
      @redirection_history = [] of Crest::Response

      set_headers!(headers)
      set_cookies!(cookies) unless cookies.empty?

      unless params.empty?
        @url = url + process_url_params(params)
      end

      unless payload.empty?
        @payload, content_type = Payload.generate(payload)
        @headers.add("Content-Type", content_type)
      end

      @max_redirects = max_redirects

      @user = options.fetch(:user, nil).as(String | Nil)
      @password = options.fetch(:password, nil).as(String | Nil)

      basic_auth(@user, @password)

      @p_addr = options.fetch(:p_addr, nil).as(String | Nil)
      @p_port = options.fetch(:p_port, nil).as(Int32 | Nil)
      @p_user = options.fetch(:p_user, nil).as(String | Nil)
      @p_pass = options.fetch(:p_pass, nil).as(String | Nil)

      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)
    end

    def execute : Crest::Response
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      client.set_proxy(@proxy)
      response = client.exec(method, url, body: payload, headers: headers)
      process_result(response)
    end

    private def process_result(http_client_res)
      response = Response.create(http_client_res, self)
      response.return!
    end

    private def parse_verb(method : String | Symbol) : String
      method.to_s.upcase
    end

    private def set_headers!(params) : HTTP::Headers
      params.each do |key, value|
        @headers.add(key, value)
      end

      @headers
    end

    # Adds "Cookie" headers for the cookies in this collection to the @header instance and returns it
    private def set_cookies!(cookies) : HTTP::Headers
      cookies.each do |k, v|
        @cookies << HTTP::Cookie.new(k.to_s, v.to_s)
      end
      @cookies.add_request_headers(@headers)
    end

    # Make Basic authorization header
    private def basic_auth(user, password)
      return unless user && password

      value = "Basic " + Base64.encode(user + ":" + password).chomp
      @headers.add("Authorization", value)
    end

    private def set_proxy!(p_addr, p_port, p_user, p_pass)
      return unless p_addr && p_port

      @proxy = HTTP::Proxy::Client.new(p_addr, p_port, username: p_user, password: p_pass)
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
