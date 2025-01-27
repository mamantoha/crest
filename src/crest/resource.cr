require "../crest"

module Crest
  # A class that can be instantiated for access to a RESTful resource,
  # including authentication, proxy and logging.
  #
  # Simple example:
  #
  # ```
  # resource = Crest::Resource.new("https://httpbin.org/get")
  # response = resource.get
  # ```
  #
  # Block style:
  #
  # ```
  # resource = Crest::Resource.new("http://httpbin.org") do |res|
  #   res.headers.merge!({"foo" => "bar"})
  # end
  #
  # response = resource["/headers"].get
  # ```
  #
  # With HTTP basic authentication:
  #
  # ```
  # resource = Crest::Resource.new("https://httpbin.org/get", user: "user", password: "password")
  # ```
  #
  # Use the `[]` syntax to allocate subresources:
  #
  # ```
  # resource = Crest::Resource.new("https://httpbin.org")
  # resource["/get"].get
  # ```
  #
  # You can pass advanced parameters like default `params`, `headers`, or `cookies`:
  #
  # ```
  # resource = Crest::Resource.new(
  #   "https://httpbin.org",
  #   params: {"key" => "key"},
  #   headers: {"Content-Type" => "application/json"},
  #   cookies: {"lang"=> "ua"}
  # )
  # response = response["/post"].post(
  #   form: {:height => 100, "width" => "100"},
  #   params: {:secret => "secret"},
  #   cookies: {"locale"=> "en_US"}
  # )
  # ```
  # If you want to stream the data from the response you can pass a block:
  #
  # ```
  # resource = Crest::Resource.new("http://httpbin.org")
  # resource["/stream/5"].get do |response|
  #   while line = response.body_io.gets
  #     puts line
  #   end
  # end
  # ```
  class Resource
    getter http_client, url,
      headers, params, cookies,
      user, password,
      logging, logger,
      p_addr, p_port, p_user, p_pass,
      handle_errors, close_connection,
      json, user_agent,
      read_timeout, write_timeout, connect_timeout

    delegate close, to: http_client

    @params = {} of String => Crest::ParamsValue
    @cookies = {} of String => Crest::ParamsValue

    def initialize(
      @url : String,
      *,
      @headers = {} of String => String,
      params = {} of String => String,
      cookies = {} of String => String,
      **options,
      &
    )
      @base_url = @url
      @params_encoder = options.fetch(:params_encoder, Crest::FlatParamsEncoder).as(Crest::ParamsEncoder.class)
      @params = @params_encoder.flatten_params(params).to_h
      @cookies = @params_encoder.flatten_params(cookies).to_h
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
      @close_connection = options.fetch(:close_connection, false).as(Bool)
      @json = options.fetch(:json, false).as(Bool)
      @user_agent = options.fetch(:user_agent, nil).as(String | Nil)
      @read_timeout = options.fetch(:read_timeout, nil).as(Time::Span?)
      @write_timeout = options.fetch(:write_timeout, nil).as(Time::Span?)
      @connect_timeout = options.fetch(:connect_timeout, nil).as(Time::Span?)

      yield self
    end

    # When block is not given.
    def initialize(@url : String, **args)
      initialize(@url, **args) { }
    end

    {% for method in Crest::HTTP_METHODS %}
      # Execute a {{method.id.upcase}} request and returns a `Crest::Response`.
      def {{method.id}}(
        suburl : String? = nil,
        form = {} of String => String,
        *,
        headers = {} of String => String,
        params = {} of String => String,
        cookies = {} of String => String
      ) : Crest::Response
        @url = concat_urls(@base_url, suburl) if suburl
        @headers = @headers.merge(headers)
        @params = merge_params(params)
        @cookies = merge_cookies(cookies)

        execute_request(:{{method.id}}, form)
      end

      # :ditto:
      def {{method.id}}(form = {} of String => String, **args) : Crest::Response
        {{method.id}}(nil, form, **args)
      end

      # Execute a {{method.id.upcase}} request and and yields the `Crest::Response` to the block.
      def {{method.id}}(
        suburl : String? = nil,
        form = {} of String => String,
        *,
        headers = {} of String => String,
        params = {} of String => String,
        cookies = {} of String => String,
        &block : Crest::Response ->
      ) : Nil
        @url = concat_urls(@base_url, suburl) if suburl
        @headers = @headers.merge(headers)
        @params = merge_params(params)
        @cookies = merge_cookies(cookies)

        execute_request(:{{method.id}}, form, &block)
      end

      # :ditto:
      def {{method.id}}(form = {} of String => String, **args, &block : Crest::Response ->) : Nil
        {{method.id}}(nil, form, **args, &block)
      end
    {% end %}

    def [](suburl)
      @url = concat_urls(@base_url, suburl)

      self
    end

    def closed?
      http_client.@io ? false : true
    end

    private def new_http_client : HTTP::Client
      uri = URI.parse(@url)
      HTTP::Client.new(uri, tls: @tls)
    end

    private def execute_request(method : Symbol, form = {} of String => String)
      Request.execute(**request_params(method, form))
    end

    private def execute_request(method : Symbol, form = {} of String => String, &block : Crest::Response ->)
      Request.execute(**request_params(method, form), &block)
    end

    private def request_params(method : Symbol, form = {} of String => String)
      {
        method:           method,
        form:             form,
        url:              @url,
        params:           @params,
        cookies:          @cookies,
        headers:          @headers,
        tls:              @tls,
        user:             @user,
        password:         @password,
        p_addr:           @p_addr,
        p_port:           @p_port,
        p_user:           @p_user,
        p_pass:           @p_pass,
        logging:          @logging,
        logger:           @logger,
        handle_errors:    @handle_errors,
        http_client:      @http_client,
        close_connection: @close_connection,
        json:             @json,
        params_encoder:   @params_encoder,
        user_agent:       @user_agent,
        read_timeout:     @read_timeout,
        write_timeout:    @write_timeout,
        connect_timeout:  @connect_timeout,
      }
    end

    private def merge_params(other : Hash)
      other = @params_encoder.flatten_params(other).to_h

      @params.try do |params|
        other = params.merge(other)
      end

      other
    end

    private def merge_cookies(other : Hash)
      other = @params_encoder.flatten_params(other).to_h

      @cookies.try do |params|
        other = params.merge(other)
      end

      other
    end

    private def concat_urls(base_url : String, path : String) : String
      base_url = base_url.ends_with?('/') ? base_url[...-1] : base_url
      path = path.starts_with?('/') ? path[1..] : path

      [base_url, path].join('/')
    end
  end
end
