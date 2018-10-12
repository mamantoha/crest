require "../crest"

module Crest
  # A class that used to make the requests
  # The result of a `Crest::Request` is a `Crest::Response` object.
  #
  # Simple example:
  #
  # ```crystal
  # request = Crest::Request.new(method: :post, url: "http://example.com/user", form: {:age => 27}, params: {:name => "Kurt"})
  # request.execute
  #
  # Crest::Request.execute(method: :post, url: "http://example.com/user", form: {:age => 27}.to_json)
  #
  # Crest::Request.post(url: "http://example.com/user", form: {:age => 27}.to_json)
  # ```
  #
  # Block style:
  #
  # ```crystal
  # request = Crest::Request.new(:get, "http://example.com") do |request|
  #   request.headers.add("foo", "bar")
  #   request.user = "username"
  #   request.password = "password"
  # end
  #
  # response = request.execute
  # ```
  #
  # Mandatory parameters:
  # * `method`
  # * `url`
  #
  # Optional parameters:
  # * `headers` a hash containing the request headers
  # * `cookies` a hash containing the request cookies
  # * `form` a hash containing form params (or a raw string)
  # * `params` a hash that represent query-string separated from the preceding part by a question mark (?)
  #    a sequence of attribute–value pairs separated by a delimiter (&).
  # * `user` and `password` for basic auth
  # * `tls` configuring TLS settings
  # * `p_addr`, `p_port`, `p_user`, `p_pass` for proxy
  # * `max_redirects` maximum number of redirections (default to `10`)
  # * `logging` enable logging (default to `false`)
  # * `logger` set logger (default to `Crest::CommonLogger`)
  # * `handle_errors` error handling (default to `true`)
  # * `http_client` instance of `HTTP::Client`
  class Request
    @method : String
    @url : String
    @tls : OpenSSL::SSL::Context::Client?
    @http_client : HTTP::Client
    @http_request : HTTP::Request
    @headers : HTTP::Headers
    @cookies : HTTP::Cookies
    @form_data : String?
    @max_redirects : Int32
    @user : String?
    @password : String?
    @proxy : HTTP::Proxy::Client?
    @p_addr : String?
    @p_port : Int32?
    @p_user : String?
    @p_pass : String?
    @logger : Crest::Logger
    @logging : Bool
    @handle_errors : Bool

    getter http_client, http_request, method, url, form_data, headers, cookies,
      max_redirects, logging, logger, handle_errors,
      proxy, p_addr, p_port, p_user, p_pass

    property redirection_history, user, password

    delegate host, port, tls?, to: @http_client

    def self.execute(method, url, **args)
      request = new(method, url, **args)
      request.execute
    end

    def initialize(
      method : Symbol,
      url : String,
      *,
      headers = {} of String => String,
      cookies = {} of String => String,
      form = {} of String => String,
      params = {} of String => String,
      max_redirects = 10,
      **options
    )
      @method = parse_verb(method)
      @url = url
      @headers = HTTP::Headers.new
      @cookies = HTTP::Cookies.new
      @redirection_history = [] of Crest::Response

      set_headers!(headers)
      set_cookies!(cookies) unless cookies.empty?
      generate_form_data!(form) if form

      unless params.empty?
        @url = url + process_url_params(params)
      end

      @max_redirects = max_redirects

      @tls = options.fetch(:tls, nil).as(OpenSSL::SSL::Context::Client | Nil)
      @http_client = options.fetch(:http_client, new_http_client).as(HTTP::Client)
      @user = options.fetch(:user, nil).as(String | Nil)
      @password = options.fetch(:password, nil).as(String | Nil)
      @p_addr = options.fetch(:p_addr, nil).as(String | Nil)
      @p_port = options.fetch(:p_port, nil).as(Int32 | Nil)
      @p_user = options.fetch(:p_user, nil).as(String | Nil)
      @p_pass = options.fetch(:p_pass, nil).as(String | Nil)
      @logger = options.fetch(:logger, Crest::CommonLogger.new).as(Crest::Logger)
      @logging = options.fetch(:logging, false).as(Bool)
      @handle_errors = options.fetch(:handle_errors, true).as(Bool)

      @http_request = HTTP::Request.new(@method, @url, body: @form_data, headers: @headers)

      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)

      yield self

      basic_auth!(@user, @password)
    end

    # When block is not given.
    def initialize(method : Symbol, url : String, **args)
      initialize(method, url, **args) { }
    end

    {% for method in Crest::HTTP_METHODS %}
      # Execute a {{method.id.upcase}} request and and yields the `Crest::Request` to the block.
      #
      # ```crystal
      # Crest::Request.{{method.id}}("http://www.example.com") do |request|
      #   request.headers.add("Content-Type", "application/json")
      #   request.user = "username"
      #   request.password = "password"
      # end
      # ```
      def self.{{method.id}}(url : String, **args) : Crest::Response
        request = Request.new(:{{method.id}}, url, **args)

        yield request

        request.basic_auth!(request.user, request.password)

        request.execute
      end

      # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
      #
      # ```crystal
      # Crest::Request.{{method.id}}("http://www.example.com")
      # ```
      def self.{{method.id}}(url : String, **args) : Crest::Response
        {{method.id}}(url, **args) { }
      end
    {% end %}

    def execute : Crest::Response
      @http_client.set_proxy(@proxy)
      @logger.request(self) if @logging

      @http_request = new_http_request(@method, @url, @headers, @form_data)

      response = @http_client.exec(@http_request)

      process_result(response)
    end

    # Convert `Request` object to cURL command
    def to_curl
      Crest::Curlify.to_curl(self)
    end

    private def new_http_client : HTTP::Client
      uri = URI.parse(@url)
      HTTP::Client.new(uri, tls: @tls)
    end

    private def new_http_request(method, path, headers, body) : HTTP::Request
      HTTP::Request.new(method, path, headers, body).tap do |request|
        request.headers["Host"] ||= host_header
      end
    end

    private def host_header
      if (tls? && port != 443) || (!tls? && port != 80)
        "#{host}:#{port}"
      else
        host
      end
    end

    private def process_result(http_client_res)
      response = Response.create(http_client_res, self)
      logger.response(response) if logging
      response.return!
    end

    private def parse_verb(method : String | Symbol) : String
      method.to_s.upcase
    end

    private def multipart?(form : Hash) : Bool
      form.any? { |_, v| v.is_a?(File) }
    end

    private def generate_form_data!(form : Hash) : String?
      return if form.empty?

      form_class = multipart?(form) ? Crest::DataForm : Crest::UrlencodedForm
      form = form_class.generate(form)

      @form_data = form.form_data
      content_type = form.content_type

      @headers.add("Content-Type", content_type)

      @form_data
    end

    private def generate_form_data!(form : String) : String?
      @form_data = form
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
    protected def basic_auth!(user, password)
      return unless user && password

      value = "Basic #{Base64.strict_encode("#{user}:#{password}")}"
      @headers.add("Authorization", value)
    end

    private def set_proxy!(p_addr, p_port, p_user, p_pass)
      return unless p_addr && p_port

      @proxy = HTTP::Proxy::Client.new(p_addr, p_port, username: p_user, password: p_pass)
    end

    # Extract the query parameters and append them to the url
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
