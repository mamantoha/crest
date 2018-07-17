require "http"
require "../crest"

module Crest
  # Response objects have several useful methods:
  #
  # * `body`: The response body as a string
  # * `status_code`: The HTTP response code
  # * `headers`: A hash of HTTP response headers
  # * `cookies`: A hash of HTTP cookies set by the server
  # * `request`: The `Crest::Request` object used to make the request
  # * `http_client_res`: The `HTTP::Client::Response` object
  # * `history`: A list of each response received in a redirection chain
  class Response
    getter http_client_res, request

    def self.create(http_client_res : HTTP::Client::Response, request : Crest::Request)
      self.new(http_client_res, request)
    end

    def initialize(@http_client_res : HTTP::Client::Response, @request : Crest::Request)
    end

    def return!
      case status_code
      when 200..207
        self
      when 301, 302, 303, 307
        check_max_redirects
        follow_redirection
      else
        raise_exception! if request.handle_errors
        self
      end
    end

    # Follow a redirection response by making a new HTTP request to the
    # redirection target.
    def follow_redirection
      url = extract_url_from_headers

      new_request = prepare_new_request(url)
      new_request.redirection_history = history + [self]
      new_request.execute
    end

    private def extract_url_from_headers
      location_url = @http_client_res.headers["Location"]
      location_uri = URI.parse(location_url)

      return location_url if location_uri.absolute?

      uri = URI.parse(@request.url)
      port = uri.port ? ":#{uri.port}" : ""

      "#{uri.scheme}://#{uri.host}#{port}#{location_url}"
    end

    private def prepare_new_request(url)
      Request.new(
        method: :get,
        url: url,
        headers: request_headers,
        max_redirects: @request.max_redirects - 1,
        cookies: cookies,
        logging: @request.logging,
        logger: @request.logger,
        handle_errors: @request.handle_errors,
        p_addr: @request.p_addr,
        p_port: @request.p_port,
        p_user: @request.p_user,
        p_pass: @request.p_pass
      )
    end

    def url : String
      @request.url
    end

    def status_code : Int32
      @http_client_res.status_code.to_i
    end

    def body
      @http_client_res.body
    end

    def headers
      @request.headers.merge!(http_client_res.headers)

      normalize_headers(@request.headers)
    end

    def cookies
      request_cookies.merge(response_cookies)
    end

    def history : Array
      @request.redirection_history
    end

    private def raise_exception!
      raise RequestFailed.subclass_by_status_code(status_code).new(self)
    end

    private def request_cookies
      cookies_to_h(@request.cookies)
    end

    private def response_cookies
      cookies_to_h(@http_client_res.cookies)
    end

    private def request_headers
      @request.headers.to_h
    end

    private def normalize_headers(headers : HTTP::Headers)
      headers.map do |header|
        key, value = header

        if value.is_a?(Array) && value.size == 1
          value = value.first
        end
        {key, value}
      end.to_h
    end

    private def cookies_to_h(cookies : HTTP::Cookies)
      cookies.to_h.map { |e| [e[1].name.to_s, URI.escape(e[1].value)] }.to_h
    end

    private def check_max_redirects
      raise_exception! if @request.max_redirects <= 0
    end
  end
end
