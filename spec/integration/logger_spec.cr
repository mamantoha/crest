require "../spec_helper"

describe Crest::Logger do
  it "logs request and response" do
    IO.pipe do |reader, writer|
      params = {:width => "100", :height => 100}
      logger = Crest::CommonLogger.new(writer)

      Crest::Request.get("#{TEST_SERVER_URL}/get", params: params, logger: logger, logging: true)

      data_time = "\\d{4}-\\d{2}-\\d{2} d{2}:\\d{2}:\\d{2}"
      url = "#{TEST_SERVER_URL}/get?width=100&height=100"
      response_body = "\"Width: 100, height: 100\""

      reader.gets.should match(Regex.new("crest | #{data_time} | .* GET.* | #{url}"))
      reader.gets.should match(Regex.new("crest | #{data_time} | .* 200.* | #{url} | #{response_body}"))
    end
  end

  describe "filters" do
    it "filter logs by regex" do
      IO.pipe do |reader, writer|
        params = {:width => "100", :height => 100, :api_key => "secret"}
        logger = Crest::CommonLogger.new(writer)
        logger.filter(/(api_key=)(\w+)/, "\\1[REMOVED]")

        Crest::Request.get("#{TEST_SERVER_URL}/get", params: params, logger: logger, logging: true)

        data_time = "\\d{4}-\\d{2}-\\d{2} d{2}:\\d{2}:\\d{2}"
        url = "#{TEST_SERVER_URL}/get?width=100&height=100&api_key=[REMOVED]"
        response_body = "\"Width: 100, height: 100\""

        reader.gets.should match(Regex.new("crest | #{data_time} | .* GET.* | #{url}"))
        reader.gets.should match(Regex.new("crest | #{data_time} | .* 200.* | #{url} | #{response_body}"))
      end
    end
  end
end
