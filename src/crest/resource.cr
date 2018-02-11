module Crest
  # A class that can be instantiated for access to a RESTful resource,
  # including authentication, proxy and logging.
  class Resource
    getter url, headers, params, user, password,
      logging, logger, p_addr, p_port, p_user, p_pass

    # Example:
    #
    # ```crystal
    # resource = Crest::Resource.new("https://httpbin.org/get")
    # response = resource.get
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
    # resource.get("/get")
    # ```
    def initialize(
      @url : String,
      *,
      headers = {} of String => String,
      params = {} of String => String,
      **options
    )
      @headers = headers
      @params = params
      @user = options.fetch(:user, nil).as(String | Nil)
      @password = options.fetch(:password, nil).as(String | Nil)
      @p_addr = options.fetch(:p_addr, nil).as(String | Nil)
      @p_port = options.fetch(:p_port, nil).as(Int32 | Nil)
      @p_user = options.fetch(:p_user, nil).as(String | Nil)
      @p_pass = options.fetch(:p_pass, nil).as(String | Nil)
      @logger = options.fetch(:logger, Crest::CommonLogger.new).as(Crest::Logger)
      @logging = options.fetch(:logging, false).as(Bool)
    end

    {% for method in %w{get delete} %}
      def {{method.id}}(
        additional_headers = {} of String => String,
        params = {} of String => String
      )
        @headers = (@headers || {} of String => String).merge(additional_headers)

        Request.execute(
          method: :{{method.id}},
          url: url,
          headers: headers,
          params: params,
          user: user,
          password: password,
          p_addr: p_addr,
          p_port: p_port,
          p_user: p_user,
          p_pass: p_pass,
          logging: logging,
          logger: logger
        )
      end
    {% end %}

    {% for method in %w{post put patch} %}
      def {{method.id}}(
        payload = {} of String => String,
        additional_headers = {} of String => String,
        params = {} of String => String
      )
        @headers = (@headers || {} of String => String).merge(additional_headers)

        Request.execute(
          method: :{{method.id}},
          url: url,
          headers: headers,
          payload: payload,
          params: params,
          user: user,
          password: password,
          p_addr: p_addr,
          p_port: p_port,
          p_user: p_user,
          p_pass: p_pass,
          logging: logging,
          logger: logger
        )
      end
    {% end %}

    def [](suburl)
      self.class.new(
        concat_urls(url, suburl),
        headers: headers,
        user: user,
        password: password,
        p_addr: p_addr,
        p_port: p_port,
        p_user: p_user,
        p_pass: p_pass,
        logging: logging,
        logger: logger
      )
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
