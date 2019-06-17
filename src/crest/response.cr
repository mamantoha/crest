require "http"
require "../crest"
require "../crest/redirector"

module Crest
  # Response objects have several useful methods:
  #
  # * `body`: The response body as a String
  # * `body_io`: The response body as a IO
  # * `status_code`: The HTTP response code
  # * `headers`: A hash of HTTP response headers
  # * `cookies`: A hash of HTTP cookies set by the server
  # * `request`: The `Crest::Request` object used to make the request
  # * `http_client_res`: The `HTTP::Client::Response` object
  # * `history`: A list of each response received in a redirection chain
  class Response
    getter http_client_res, request

    delegate body, to: http_client_res
    delegate body_io, to: http_client_res
    delegate to_curl, to: request

    def initialize(@http_client_res : HTTP::Client::Response, @request : Crest::Request)
    end

    def return! : Crest::Response
      redirector = Redirector.new(self, request)
      redirector.follow
    end

    def return!(&block : Crest::Response ->)
      redirector = Redirector.new(self, request)
      redirector.follow(&block)
    end

    def url : String
      @request.url
    end

    def status_code : Int32
      @http_client_res.status_code.to_i
    end

    def headers
      headers = @request.headers.dup.merge!(http_client_res.headers)

      normalize_headers(headers)
    end

    def cookies
      request_cookies.merge(response_cookies)
    end

    def history : Array
      @request.redirection_history
    end

    # Extracts filename from Content-Disposition header
    def filename : String?
      filename_regex = /filename\*?=['"]?(?:UTF-\d['"]*)?([^;\r\n"']*)['"]?;?/xi

      if match_data = headers.fetch("Content-Disposition", "").as(String).match(filename_regex)
        return match_data[1]
      end
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

    module Helpers
      def invalid?
        status_code < 100 || status_code >= 600
      end

      def informational?
        (100..199).includes?(status_code)
      end

      def success?
        (200..299).includes?(status_code)
      end

      def redirection?
        (300..399).includes?(status_code)
      end

      def redirect?
        [301, 302, 303, 307, 308].includes?(status_code)
      end

      def client_error?
        (400..499).includes?(status_code)
      end

      def server_error?
        (500..599).includes?(status_code)
      end
    end

    include Helpers
  end
end
