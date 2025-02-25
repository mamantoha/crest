require "../crest"

module Crest
  # A class that used to make the requests
  # The result of a `Crest::Request` is a `Crest::Response` object.
  #
  # Simple example:
  #
  # ```
  # request = Crest::Request.new(:post, "http://httpbin.org/post", {"age" => 27}, params: {:name => "Kurt"})
  # request.execute
  #
  # Crest::Request.execute(:post, "http://httpbin.org/post", {"age" => 27}, json: true)
  #
  # Crest::Request.post("http://httpbin.org/post", {"age" => 27}, json: true)
  # ```
  #
  # Block style:
  #
  # ```
  # request = Crest::Request.new(:get, "http://httpbin.org/get") do |request|
  #   request.headers.add("foo", "bar")
  #   request.user = "username"
  #   request.password = "password"
  # end
  #
  # response = request.execute
  # ```
  #
  # Mandatory parameters:
  # - `method`
  # - `url`
  #
  # Optional parameters:
  # - `headers` a hash containing the request headers
  # - `cookies` a hash containing the request cookies
  # - `form` a hash containing form data (or a raw string)
  # - `params` a hash that represent query params (or a raw string) - a string separated from the preceding part by a question mark (?)
  #    and a sequence of attribute–value pairs separated by a delimiter (&).
  # - `params_encoder` params encoder (default to `Crest::FlatParamsEncoder`)
  # - `auth` access authentication method `basic` or `digest` (default to `basic`)
  # - `user` and `password` for authentication
  # - `tls` configuring TLS settings
  # - `p_addr`, `p_port`, `p_user`, `p_pass` for proxy
  # - `json` make a JSON request with the appropriate HTTP headers (default to `false`)
  # - `multipart` make a multipart request with the appropriate HTTP headers even if not sending a file (default to `false`)
  # - `user_agent` set "User-Agent" HTTP header (default to `Crest::USER_AGENT`)
  # - `max_redirects` maximum number of redirects (default to `10`)
  # - `logging` enable logging (default to `false`)
  # - `logger` set logger (default to `Crest::CommonLogger`)
  # - `handle_errors` error handling (default to `true`)
  # - `close_connection` close the connection after request is completed (default to `true`)
  # - `http_client` instance of `HTTP::Client`
  # - `read_timeout` read timeout (default to `nil`)
  # - `write_timeout` write timeout (default to `nil`)
  # - `connect_timeout` connect timeout (default to `nil`)
  class Request
    @method : String
    @url : String
    @tls : OpenSSL::SSL::Context::Client?
    @http_client : HTTP::Client
    @http_request : HTTP::Request
    @headers : HTTP::Headers
    @cookies : HTTP::Cookies
    @form_data : String | Bytes | IO | Nil
    @max_redirects : Int32
    @auth : String
    @user : String?
    @password : String?
    @proxy : HTTP::Proxy::Client?
    @p_addr : String?
    @p_port : Int32?
    @p_user : String?
    @p_pass : String?
    @json : Bool
    @multipart : Bool
    @user_agent : String?
    @logger : Crest::Logger
    @logging : Bool
    @handle_errors : Bool
    @close_connection : Bool
    @read_timeout : Time::Span?
    @write_timeout : Time::Span?
    @connect_timeout : Time::Span?

    getter http_client, http_request, method, url, tls, form_data, headers, cookies,
      max_redirects, logging, logger, handle_errors, close_connection,
      auth, proxy, p_addr, p_port, p_user, p_pass, json, multipart, user_agent,
      read_timeout, write_timeout, connect_timeout

    property redirection_history, user, password

    delegate host, port, tls?, close, to: @http_client

    def self.execute(method, url, form = {} of String => String, **args) : Crest::Response
      request = new(method, url, form, **args)
      request.execute
    end

    def self.execute(method, url, form = {} of String => String, **args, &block : Crest::Response ->) : Nil
      request = new(method, url, form, **args)
      request.execute(&block)
    end

    def initialize(
      method : Symbol,
      url : String,
      form = {} of String => String,
      *,
      headers = {} of String => String,
      cookies = {} of String => String,
      params = {} of String => String,
      max_redirects = 10,
      **options,
      &
    )
      @method = parse_verb(method)
      @url = url
      @headers = HTTP::Headers.new
      @cookies = HTTP::Cookies.new
      @json = options.fetch(:json, false).as(Bool)
      @multipart = options.fetch(:multipart, false).as(Bool)
      @params_encoder = options.fetch(:params_encoder, Crest::FlatParamsEncoder).as(Crest::ParamsEncoder.class)
      @user_agent = options.fetch(:user_agent, nil).as(String | Nil)
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
      @auth = options.fetch(:auth, "basic").as(String)
      @user = options.fetch(:user, nil).as(String | Nil)
      @password = options.fetch(:password, nil).as(String | Nil)
      @p_addr = options.fetch(:p_addr, nil).as(String | Nil)
      @p_port = options.fetch(:p_port, nil).as(Int32 | Nil)
      @p_user = options.fetch(:p_user, nil).as(String | Nil)
      @p_pass = options.fetch(:p_pass, nil).as(String | Nil)
      @logger = options.fetch(:logger, Crest::CommonLogger.new).as(Crest::Logger)
      @logging = options.fetch(:logging, false).as(Bool)
      @handle_errors = options.fetch(:handle_errors, true).as(Bool)
      @close_connection = options.fetch(:close_connection, true).as(Bool)
      @read_timeout = options.fetch(:read_timeout, nil).as(Time::Span?)
      @write_timeout = options.fetch(:write_timeout, nil).as(Time::Span?)
      @connect_timeout = options.fetch(:connect_timeout, nil).as(Time::Span?)

      @http_request = new_http_request(@method, @url, @headers, @form_data)

      set_proxy!(@p_addr, @p_port, @p_user, @p_pass)
      set_timeouts!

      yield self
    end

    # When block is not given.
    def initialize(method : Symbol, url : String, form = {} of String => String, **args)
      initialize(method, url, form, **args) { }
    end

    {% for method in Crest::HTTP_METHODS %}
      # Execute a {{method.id.upcase}} request and and yields the `Crest::Response` to the block.
      #
      # ```
      # Crest::Request.{{method.id}}("http://httpbin.org/{{method.id}}") do |resp|
      #   while line = resp.body_io.gets
      #     puts line
      #   end
      # end
      # ```
      def self.{{method.id}}(url : String, form = {} of String => String, **args, &block : Crest::Response ->) : Nil
        request = Request.new(:{{method.id}}, url, form, **args)

        response = request.execute(&block)
      end

      # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
      #
      # ```
      # Crest::Request.{{method.id}}("http://httpbin.org/{{method.id}}")
      # ```
      def self.{{method.id}}(url : String, form = {} of String => String, **args) : Crest::Response
        request = Request.new(:{{method.id}}, url, form, **args)

        request.execute
      end
    {% end %}

    # Execute HTTP request
    def execute : Crest::Response
      @proxy.try { |proxy| @http_client.proxy = proxy }
      authenticate!
      @logger.request(self) if @logging

      @http_request = new_http_request(@method, @url, @headers, @form_data)

      http_response = @http_client.exec(@http_request)

      process_result(http_response)
    ensure
      @http_client.close if @close_connection
    end

    # Execute streaming HTTP request
    def execute(&block : Crest::Response ->) : Nil
      @proxy.try { |proxy| @http_client.proxy = proxy }
      authenticate!
      @logger.request(self) if @logging

      @http_request = new_http_request(@method, @url, @headers, @form_data)

      @http_client.exec(@http_request) do |http_response|
        response = process_result(http_response, &block)

        if response
          yield response
        end
      end
    ensure
      @http_client.close if @close_connection
    end

    def closed?
      http_client.@io ? false : true
    end

    private def process_result(http_client_res) : Crest::Response
      response = Response.new(http_client_res, self)
      logger.response(response) if logging
      response.return!
    end

    private def process_result(http_client_res, &block : Crest::Response ->)
      response = Response.new(http_client_res, self)
      logger.response(response) if logging
      response.return!(&block)
    end

    # Convert `Request` object to cURL command
    def to_curl
      Crest::Curlify.to_curl(self)
    end

    private def new_http_client : HTTP::Client
      uri = URI.parse(@url)
      uri = normalize_uri(uri)

      if uri.scheme == "https"
        HTTP::Client.new(uri, tls: @tls)
      else
        HTTP::Client.new(uri)
      end
    end

    private def new_http_request(method, url, headers, body) : HTTP::Request
      resource = URI.parse(url).request_target

      HTTP::Request.new(method, resource, headers, body).tap do |request|
        # Set default headers
        request.headers["Accept"] ||= @json ? "application/json" : "*/*"
        request.headers["Host"] ||= host_header
        request.headers["User-Agent"] ||= Crest::USER_AGENT
      end
    end

    # Normalizes a `uri` using the Punycode algorithm as necessary.
    # To support IDN (https://en.wikipedia.org/wiki/Internationalized_domain_name)
    # The result will be `uri` with a ASCII-only host.
    private def normalize_uri(uri : URI) : URI
      if hostname = uri.host
        return uri if hostname.ascii_only?

        uri.host = URI::Punycode.to_ascii(hostname)
      end

      uri
    end

    private def host_header
      if (tls? && port != 443) || (!tls? && port != 80)
        "#{host}:#{port}"
      else
        host
      end
    end

    private def parse_verb(method : String | Symbol) : String
      method.to_s.upcase
    end

    private def multipart?(form : Hash) : Bool
      @params_encoder.flatten_params(form).any?(&.[1].is_a?(IO)) || @multipart == true
    end

    private def form_class(form : Hash)
      if @json
        Crest::JSONForm
      elsif multipart?(form)
        Crest::DataForm
      else
        Crest::UrlencodedForm
      end
    end

    private def generate_form_data!(form : Hash) : String | Bytes | IO | Nil
      return if form.empty?

      generated_form = form_class(form).generate(form, @params_encoder)

      @headers["Content-Type"] = generated_form.content_type
      @form_data = generated_form.form_data
    end

    private def generate_form_data!(form : String | Bytes | IO) : String | Bytes | IO | Nil
      @form_data = form
    end

    private def set_headers!(params) : HTTP::Headers
      params.each do |key, value|
        @headers.add(key, value)
      end

      @headers["User-Agent"] = @user_agent.to_s if @user_agent

      @headers
    end

    # Adds "Cookie" headers for the cookies in this collection to the @header instance and returns it
    private def set_cookies!(cookies) : HTTP::Headers
      cookies = @params_encoder.flatten_params(cookies)

      cookies.each do |k, v|
        @cookies << HTTP::Cookie.new(k.to_s, v.to_s)
      end

      @cookies.add_request_headers(@headers)
    end

    protected def authenticate!
      return unless @user && @password

      if @auth == "basic"
        basic_auth!
      else
        digest_auth!
      end
    end

    private def basic_auth!
      auth = "Basic #{Base64.strict_encode("#{@user}:#{@password}")}"

      @headers.add("Authorization", auth)
    end

    private def digest_auth!
      uri = URI.parse(@url)
      uri.user = @user
      uri.password = @password

      response = digest_auth_response(uri)

      www_authenticate = response.headers["WWW-Authenticate"]

      digest_auth = HTTP::Client::DigestAuth.new
      auth = digest_auth.auth_header(uri, www_authenticate, @method)

      @headers.add("Authorization", auth)
    end

    private def digest_auth_response(uri)
      @http_client.exec(@method, uri.to_s)
    end

    private def set_proxy!(p_addr, p_port, p_user, p_pass)
      return unless p_addr && p_port

      @proxy = HTTP::Proxy::Client.new(p_addr, p_port, username: p_user, password: p_pass)
    end

    private def set_timeouts!
      @read_timeout.try { |timeout| @http_client.read_timeout = timeout }
      @write_timeout.try { |timeout| @http_client.write_timeout = timeout }
      @connect_timeout.try { |timeout| @http_client.connect_timeout = timeout }
    end

    # Extract the query parameters and append them to the `url`
    private def process_url_params(params : Hash | String) : String
      query_string = params.is_a?(String) ? params : @params_encoder.encode(params)

      if url.includes?("?")
        "&" + query_string
      else
        "?" + query_string
      end
    end
  end
end
