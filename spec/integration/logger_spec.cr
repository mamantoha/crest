require "../spec_helper"

describe Crest::Logger do
  describe "filters" do
    it "filter logs by regex" do
      IO.pipe do |r, w|
        params = {:width => "100", :height => 100, :api_key => "secret"}
        logger = Crest::CommonLogger.new(w)
        logger.filter(/(api_key=)(\w+)/, "\\1[REMOVED]")

        Crest::Request.get("#{TEST_SERVER_URL}/resize", params: params, logger: logger, logging: true)

        data_time = "\\d{4}-\\d{2}-\\d{2} d{2}:\\d{2}:\\d{2}"
        url = "#{TEST_SERVER_URL}/resize?width=100&height=100&api_key=[REMOVED]"
        params = "\"Width: 100, height: 100\""

        r.gets.should match(Regex.new("crest | #{data_time} | .* GET.* | #{url}"))
        r.gets.should match(Regex.new("crest | #{data_time} | .* 200.* | #{url} | #{params}"))
      end
    end
  end
end
