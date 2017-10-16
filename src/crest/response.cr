module Crest
  class Response

    @http_client_res : HTTP::Client::Response
    @request : Crest::Request

    getter http_client_res, request, code

    def self.create(http_client_res : HTTP::Client::Response , request : Crest::Request)
      result = self.new(http_client_res, request)
      result
    end

    def initialize(http_client_res, request)
      @http_client_res = http_client_res
      @request = request
    end

    def return!
      case status_code
      when 200..207
        self
      when 301, 302, 303, 307
        check_max_redirects
        follow_redirection
      else
        raise RequestFailed.new(self, status_code)
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

      # prepare new request
      max_redirects = @request.max_redirects - 1
      new_req = Request.new(method: :get, url: url, headers: headers, max_redirects: max_redirects)

      # execute redirected request
      new_req.execute
    end

    # HTTP status code
    def status_code : Int32
      @http_client_res.status_code.to_i
    end

    def body
      @http_client_res.body
    end

    # A hash of the headers, beautified with strings and underscores.
    # e.g. "Content-type" will become "content_type".
    def headers
      beautify_headers(@request.headers)
    end

    private def beautify_headers(headers : HTTP::Headers)
      raw_headers = headers.to_h
      headers = {} of String => String
      raw_headers.each do |item|
        k, v = item
        key = k.tr("-", "_").downcase
        value = v.join(", ").to_s
        headers[key] = value
      end
      headers
    end

    private def check_max_redirects
      if @request.max_redirects <= 0
        raise RequestFailed.new(self, status_code)
      end
    end

  end
end
