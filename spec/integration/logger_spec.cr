require "../spec_helper"

describe Crest::Logger do
  describe "filters" do
    it "filter logs by regex" do
      IO.pipe do |r, w|
        params = {:width => "100", :height => 100, :api_key => "secret"}
        logger = Crest::CommonLogger.new(w)

        Crest::Request.get("#{TEST_SERVER_URL}/resize", params: params, logger: logger, logging: true) do |request|
          request.logger.filter(/(api_key=)(\w+)/, "\\1[REMOVED]")
        end

        r.gets.should match(/[REMOVED]/)
        r.gets.should match(/[REMOVED]/)
      end
    end
  end
end
