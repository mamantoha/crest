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
      cookie_jar,
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
      @cookie_jar : HTTP::CookieJar? = nil,
      @params_encoder : Crest::ParamsEncoder.class = Crest::FlatParamsEncoder,
      @tls : OpenSSL::SSL::Context::Client? = nil,
      http_client : HTTP::Client? = nil,
      @user : String? = nil,
      @password : String? = nil,
      @p_addr : String? = nil,
      @p_port : Int32? = nil,
      @p_user : String? = nil,
      @p_pass : String? = nil,
      @logger : Crest::Logger = Crest::CommonLogger.new,
      @logging : Bool = false,
      @handle_errors : Bool = true,
      @close_connection : Bool = false,
      @json : Bool = false,
      @user_agent : String? = nil,
      @read_timeout : Time::Span? = nil,
      @write_timeout : Time::Span? = nil,
      @connect_timeout : Time::Span? = nil,
      &
    )
      @params = @params_encoder.flatten_params(params).to_h
      @cookies = @params_encoder.flatten_params(cookies).to_h
      @http_client = http_client || new_http_client

      yield self
    end

    # When block is not given.
    def initialize(@url : String, **args)
      initialize(@url, **args) { }
    end

    {% for method in Crest::HTTP_METHODS %}
      # Execute a {{ method.id.upcase }} request and returns a `Crest::Response`.
      def {{ method.id }}(
        suburl : String? = nil,
        form = {} of String => String,
        *,
        headers = {} of String => String,
        params = {} of String => String,
        cookies = {} of String => String
      ) : Crest::Response
        request_url = suburl ? concat_urls(@url, suburl) : @url

        execute_request(
          :{{ method.id }},
          request_url,
          form,
          request_headers(headers),
          merge_params(params),
          merge_cookies(cookies)
        )
      end

      # :ditto:
      def {{ method.id }}(form = {} of String => String, **args) : Crest::Response
        {{ method.id }}(nil, form, **args)
      end

      # Execute a {{ method.id.upcase }} request and and yields the `Crest::Response` to the block.
      def {{ method.id }}(
        suburl : String? = nil,
        form = {} of String => String,
        *,
        headers = {} of String => String,
        params = {} of String => String,
        cookies = {} of String => String,
        &block : Crest::Response ->
      ) : Nil
        request_url = suburl ? concat_urls(@url, suburl) : @url

        execute_request(
          :{{ method.id }},
          request_url,
          form,
          request_headers(headers),
          merge_params(params),
          merge_cookies(cookies),
          &block
        )
      end

      # :ditto:
      def {{ method.id }}(form = {} of String => String, **args, &block : Crest::Response ->) : Nil
        {{ method.id }}(nil, form, **args, &block)
      end
    {% end %}

    def [](suburl)
      self.class.new(
        concat_urls(@url, suburl),
        headers: @headers.dup,
        params: @params.dup,
        cookies: @cookies.dup,
        cookie_jar: @cookie_jar,
        params_encoder: @params_encoder,
        tls: @tls,
        http_client: @http_client,
        user: @user,
        password: @password,
        p_addr: @p_addr,
        p_port: @p_port,
        p_user: @p_user,
        p_pass: @p_pass,
        logger: @logger,
        logging: @logging,
        handle_errors: @handle_errors,
        close_connection: @close_connection,
        json: @json,
        user_agent: @user_agent,
        read_timeout: @read_timeout,
        write_timeout: @write_timeout,
        connect_timeout: @connect_timeout,
      )
    end

    def closed?
      http_client.@io ? false : true
    end

    private def new_http_client : HTTP::Client
      uri = URI.parse(@url)
      HTTP::Client.new(uri, tls: @tls)
    end

    private def execute_request(
      method : Symbol,
      url : String,
      form = {} of String => String,
      headers = {} of String => String,
      params = {} of String => Crest::ParamsValue,
      cookies = {} of String => Crest::ParamsValue,
    )
      Request.execute(**request_params(method, url, form, headers, params, cookies))
    end

    private def execute_request(
      method : Symbol,
      url : String,
      form = {} of String => String,
      headers = {} of String => String,
      params = {} of String => Crest::ParamsValue,
      cookies = {} of String => Crest::ParamsValue,
      &block : Crest::Response ->
    )
      Request.execute(**request_params(method, url, form, headers, params, cookies), &block)
    end

    private def request_params(
      method : Symbol,
      url : String,
      form = {} of String => String,
      headers = {} of String => String,
      params = {} of String => Crest::ParamsValue,
      cookies = {} of String => Crest::ParamsValue,
    )
      {
        method:           method,
        form:             form,
        url:              url,
        params:           params,
        cookies:          cookies,
        cookie_jar:       @cookie_jar,
        headers:          headers,
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

    private def request_headers(other : Hash)
      @headers.merge(other)
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
      base_url = base_url.chomp('/')
      path = path.lchop('/')

      [base_url, path].join('/')
    end
  end
end
