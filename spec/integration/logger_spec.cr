require "../spec_helper"

describe Crest::Logger do
  describe "filters" do
    it "filter logs by regex" do
      IO.pipe do |r, w|
        params = {:width => "100", :height => 100, :api_key => "secret"}
        logger = Crest::CommonLogger.new(w)
        logger.filter(/(api_key=)(\w+)/, "\\1[REMOVED]")

        Crest::Request.get("#{TEST_SERVER_URL}/resize", params: params, logger: logger, logging: true)

        r.gets.should match(/crest \| \d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2} \|.* GET.* \| http\:\/\/0\.0\.0\.0\:4567\/resize\?width\=100&height\=100&api_key\=\[REMOVED\]/)
        r.gets.should match(/crest \| \d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2} \|.* 200.* \| http\:\/\/0\.0\.0\.0\:4567\/resize\?width\=100&height\=100&api_key\=\[REMOVED\] \| "Width\: 100, height\: 100"/)
      end
    end
  end
end
