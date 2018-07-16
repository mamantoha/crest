module Crest
  class Curlify
    def initialize(@request : Crest::Request)
    end

    def call
      ["curl", method, url, data, headers].reject(&.empty?).join(" ")
    end

    private def method
      "-X #{@request.method}"
    end

    private def url
      "#{@request.url}"
    end

    private def data
      return "" unless @request.form_data
      "-d '#{convert_form_data}'"
    end

    private def headers
      headers = [] of String
      @request.headers.each do |k, v|
        value = v.is_a?(Array) ? v.first.split(";").first : v
        headers << "-H '#{k}: #{value}'"
      end

      headers.join(" ")
    end

    private def convert_form_data : String
      result = {} of String => String

      HTTP::FormData.parse(@request.http_request) do |part|
        result[part.name] = part.body.gets_to_end
      end

      result.reduce([] of String) { |memo, i| memo << "#{i[0]}=#{i[1]}" }.join("&")
    rescue HTTP::FormData::Error
      @request.http_request.body.to_s
    end
  end
end
