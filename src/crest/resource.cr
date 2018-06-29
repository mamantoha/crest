module Crest
  # A class that can be instantiated for access to a RESTful resource,
  # including authentication, proxy and logging.
  #
  # Simple example:
  #
  # ```crystal
  # resource = Crest::Resource.new("https://httpbin.org/get")
  # response = resource.get
  # ```
  #
  # Block style:
  #
  # ```crystal
  # resource = Crest::Resource.new("http://httpbin.org") do |resource|
  #   resource.headers.merge!({"foo" => "bar"})
  # end
  #
  # response = resource["/headers"].get
  # ```
  #
  # With HTTP basic authentication:
  #
  # ```crystal
  # resource = Crest::Resource.new("https://httpbin.org/get", user: "user", password: "password")
  # ```
  #
  # Use the `[]` syntax to allocate subresources:
  #
  # ```crystal
  # resource = Crest::Resource.new("https://httpbin.org")
  # resource["/get"].get
  # ```
  #
  # You can pass advanced parameters like default `params` or `headers`:
  #
  # ```crystal
  # resource = Crest::Resource.new(
  #   "https://httpbin.org",
  #   params: {"key" => "key"},
  #   headers: {"Content-Type" => "application/json"}
  # )
  # response = response["/post"].post(
  #   payload: {:height => 100, "width" => "100"},
  #   params: {:secret => "secret"}
  # )
  # ```
  class Resource
    getter http_client, url, user, password, headers, params,
      logging, logger, handle_errors, p_addr, p_port, p_user, p_pass

    def initialize(
      @url : String,
      *,
      @headers = {} of String => String,
      @params : Params = {} of String => String,
      **options
    )
      http_client = options.fetch(:http_client, nil).as(HTTP::Client | Nil)
      if http_client
        @http_client = http_client
      else
        uri = URI.parse(@url)
        @http_client = HTTP::Client.new(uri)
      end

      @user = options.fetch(:user, nil).as(String | Nil)
      @password = options.fetch(:password, nil).as(String | Nil)
      @p_addr = options.fetch(:p_addr, nil).as(String | Nil)
      @p_port = options.fetch(:p_port, nil).as(Int32 | Nil)
      @p_user = options.fetch(:p_user, nil).as(String | Nil)
      @p_pass = options.fetch(:p_pass, nil).as(String | Nil)
      @logger = options.fetch(:logger, Crest::CommonLogger.new).as(Crest::Logger)
      @logging = options.fetch(:logging, false).as(Bool)
      @handle_errors = options.fetch(:handle_errors, true).as(Bool)

      yield self
    end

    # When block is not given.
    def initialize(@url : String, **args)
      initialize(@url, **args) { }
    end

    {% for method in Crest::HTTP_METHODS %}
      def {{method.id}}(
        payload = {} of String => String,
        headers = {} of String => String,
        params = {} of String => String
      )
        @headers = @headers.merge(headers)
        @params = merge_params(params)

        execute_request(:{{method.id}}, payload)
      end
    {% end %}

    def [](suburl)
      @url = concat_urls(url, suburl)

      self
    end

    private def execute_request(method : Symbol, payload = {} of String => String)
      Request.execute(
        method: method,
        url: url,
        params: params,
        headers: headers,
        payload: payload,
        user: user,
        password: password,
        p_addr: p_addr,
        p_port: p_port,
        p_user: p_user,
        p_pass: p_pass,
        logging: logging,
        logger: logger,
        handle_errors: handle_errors,
        http_client: http_client,
      )
    end

    private def merge_params(other = {} of String => String)
      @params.try do |params|
        other = params.merge(other)
      end
      return other
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
