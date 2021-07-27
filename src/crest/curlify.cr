module Crest
  # Class to convert `Crest::Request` object to cURL command
  #
  # ```
  # request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"title" => "New Title"})
  # Crest::Curlify.to_curl(request)
  # => "curl -X POST http://httpbin.org/post -d 'title=New+Title' -H 'Content-Type: application/x-www-form-urlencoded'"
  # ```
  class Curlify
    # Returns string with cURL command by provided `Crest::Request` object
    def self.to_curl(request : Crest::Request)
      new(request).to_curl
    end

    def initialize(@request : Crest::Request)
    end

    def to_curl
      ["curl", method, url, proxy, basic_auth, form_data, headers].reject(&.empty?).join(" ")
    end

    private def method
      "-X #{@request.method}"
    end

    private def url
      "#{@request.url}"
    end

    private def headers : String
      headers = [] of String

      @request.headers.each do |k, v|
        next if k == "Authorization" && basic_auth? && includes_authorization_header?

        value =
          if v.is_a?(Array)
            if k == "Content-Type"
              v.first.split(";").first
            else
              v.first
            end
          else
            v
          end

        headers << "-H '#{k}: #{value}'"
      end

      headers.join(" ")
    end

    private def form_data : String
      raise HTTP::FormData::Error.new "Cannot extract form-data from HTTP request: body is empty" unless @request.form_data
      body = IO::Memory.new(@request.form_data.to_s)

      boundary = @request.headers["Content-Type"]?.try { |header| MIME::Multipart.parse_boundary(header) }
      raise HTTP::FormData::Error.new "Cannot extract form-data from HTTP request: could not find boundary in Content-Type" unless boundary

      form_data = [] of String

      HTTP::FormData.parse(body, boundary) do |part|
        value =
          if filename = part.filename
            "@#{File.expand_path(filename)}"
          else
            part.body.gets_to_end
          end

        form_data << "-F '#{part.name}=#{value}'"
      end

      form_data.join(" ")
    rescue HTTP::FormData::Error
      body = @request.form_data.to_s

      body.empty? ? "" : "-d '#{body}'"
    end

    private def basic_auth : String
      return "" unless basic_auth?

      params = [] of String

      params << "--digest" if @request.auth == "digest"
      params << "--user #{@request.user}:#{@request.password}"

      params.join(" ")
    end

    # --proxy <[protocol://][user:password@]proxyhost[:port]> url
    private def proxy : String
      return "" unless @request.proxy

      params = [] of String

      params << "--proxy "
      params << "#{@request.p_user}:#{@request.p_pass}@" if proxy_auth?
      params << "#{@request.p_addr}:#{@request.p_port}"

      params.join
    end

    private def basic_auth? : Bool
      @request.user && @request.password ? true : false
    end

    private def proxy_auth? : Bool
      @request.p_user && @request.p_pass ? true : false
    end

    private def includes_authorization_header?
      @request.headers.includes_word?("Authorization", "Basic") ||
        @request.headers.includes_word?("Authorization", "Digest")
    end
  end
end
