require "http"
require "./request"

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
        raise RequestFailed.new(self)
      end
    end

    # Follow a redirection response by making a new HTTP request to the
    # redirection target.
    #
    def follow_redirection
      # parse location header and merge into existing URL
      url = @http_client_res.headers["Location"]

      # handle relative redirects
      unless url.starts_with?("http")
        uri = URI.parse(@request.url)
        port = uri.port ? ":#{uri.port}" : ""
        url = "#{uri.scheme}://#{uri.host}#{port}#{url}"
      end

      max_redirects = @request.max_redirects - 1

      # prepare new request
      new_request = Request.new(
        method: :get,
        url: url,
        headers: headers,
        max_redirects: max_redirects,
        cookies: cookies,
        logging: @request.logging,
        logger: @request.logger,
        p_addr: @request.p_addr,
        p_port: @request.p_port,
        p_user: @request.p_user,
        p_pass: @request.p_pass
      )

      # append self to redirection history
      new_request.redirection_history = history + [self]

      # execute redirected request
      new_request.execute
    end

    def url : String
      @request.url
    end

    # HTTP status code
    def status_code : Int32
      @http_client_res.status_code.to_i
    end

    def body
      @http_client_res.body
    end

    # A hash of the headers.
    def headers
      @request.headers.to_h
    end

    def cookies
      request_cookies.merge(response_cookies)
    end

    def history : Array
      @request.redirection_history || [] of self
    end

    private def request_cookies
      cookies_to_h(@request.cookies)
    end

    private def response_cookies
      cookies_to_h(@http_client_res.cookies)
    end

    private def cookies_to_h(cookies : HTTP::Cookies)
      cookies.to_h.map { |e| [e[1].name.to_s, URI.escape(e[1].value)] }.to_h
    end

    private def check_max_redirects
      if @request.max_redirects <= 0
        raise RequestFailed.new(self)
      end
    end
  end
end
