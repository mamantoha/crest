require "http"
require "../crest"
require "../crest/redirector"

module Crest
  # Response objects have several useful methods:
  #
  # - `body`: The response body as a `String`
  # - `body_io`: The response body as a `IO`
  # - `status`: The response status as a `HTTP::Status`
  # - `status_code`: The HTTP response code
  # - `headers`: A hash of HTTP response headers
  # - `cookies`: A hash of HTTP cookies set by the server
  # - `request`: The `Crest::Request` object used to make the request
  # - `http_client_res`: The `HTTP::Client::Response` object
  # - `history`: A list of each response received in a redirection chain
  class Response
    getter http_client_res, request

    delegate body, to: http_client_res
    delegate body_io, to: http_client_res
    delegate status, to: http_client_res
    delegate status_code, to: http_client_res
    delegate informational?, success?, redirection?, client_error?, server_error?, to: status
    delegate to_curl, to: request

    def initialize(@http_client_res : HTTP::Client::Response, @request : Crest::Request)
      http_client_res.headers
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

    def headers
      normalize_headers(http_client_res.headers)
    end

    def cookies
      request_cookies.merge(response_cookies)
    end

    def history : Array
      @request.redirection_history
    end

    # Extracts filename from "Content-Disposition" header
    def filename : String?
      filename_regex = /filename\*?=['"]?(?:UTF-\d['"]*)?([^;\r\n"']*)['"]?;?/xi

      if match_data = http_client_res.headers.fetch("Content-Disposition", "").match(filename_regex)
        return match_data[1]
      end
    end

    # Size of the message body in bytes taken from "Content-Length" header
    def content_length : Int64
      http_client_res.headers["Content-Length"].to_i64
    end

    def invalid?
      status_code < 100 || status_code >= 600
    end

    def redirect?
      [301, 302, 303, 307, 308].includes?(status_code)
    end

    def to_s(io : IO) : Nil
      {% if compare_versions(Crystal::VERSION, "1.1.1") > 0 %}
        io.write_string(body.to_slice)
      {% else %}
        io.write_utf8(body.to_slice)
      {% end %}
    end

    def inspect
      "<Crest::Response #{status_code.inspect} #{body_truncated(10).inspect}>"
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
      {% if compare_versions(Crystal::VERSION, "1.1.1") > 0 %}
        cookies.to_h.map { |e| [e[1].name.to_s, URI.encode_path(e[1].value)] }.to_h
      {% else %}
        cookies.to_h.map { |e| [e[1].name.to_s, URI.encode(e[1].value)] }.to_h
      {% end %}
    end

    private def body_truncated(size)
      if body.size > size
        body[0..size] + "..."
      else
        body
      end
    end
  end
end
