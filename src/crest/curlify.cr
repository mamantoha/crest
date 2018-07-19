module Crest
  class Curlify
    def initialize(@request : Crest::Request)
    end

    def call
      ["curl", method, url, basic_auth, form_data, headers].reject(&.empty?).join(" ")
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
        next if k == "Authorization" && basic_auth? && @request.headers.includes_word?("Authorization", "Basic")

        value = v.is_a?(Array) ? v.first.split(";").first : v
        headers << "-H '#{k}: #{value}'"
      end

      headers.join(" ")
    end

    private def form_data : String
      form_data = [] of String

      HTTP::FormData.parse(@request.http_request) do |part|
        value = part.filename ? "@#{part.filename}" : part.body.gets_to_end

        form_data << "-F '#{part.name}=#{value}'"
      end

      form_data.join(" ")
    rescue HTTP::FormData::Error
      body = @request.http_request.body.to_s

      body.empty? ? "" : "-d '#{body}'"
    end

    private def basic_auth : String
      if basic_auth?
        "--user #{@request.user}:#{@request.password}"
      else
        ""
      end
    end

    private def basic_auth? : Bool
      @request.user && @request.password ? true : false
    end
  end
end
