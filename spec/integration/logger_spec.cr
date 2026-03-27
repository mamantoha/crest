require "../spec_helper"

private class FilteredLogger < Crest::Logger
  def initialize(io : IO = STDOUT)
    super
    filter(/(access_token=)([^&]+)/, "\\1[REMOVED]")
  end

  def request(request : Crest::Request) : Nil
    info(">> | %s | %s" % [request.method, request.url])
  end

  def response(response : Crest::Response) : Nil
    info("<< | %s | %s" % [response.status_code, response.url])
  end
end

describe Crest::Logger do
  it "logs request and response" do
    IO.pipe do |reader, writer|
      params = {:width => "100", :height => 100}
      logger = Crest::CommonLogger.new(writer)

      Crest::Request.get("#{TEST_SERVER_URL}/get", params: params, logger: logger, logging: true)

      date_time = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"
      url = "#{TEST_SERVER_URL}/get?width=100&height=100"

      reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} \\| .*GET.* \\| #{Regex.escape(url)}\\z"))
      reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} \\| .*200.* \\| #{Regex.escape(url)} \\| \".*\"\\z"))
    end
  end

  describe "filters" do
    it "filter logs by regex" do
      IO.pipe do |reader, writer|
        params = {:width => "100", :height => 100, :access_token => "secret", :v => "2"}
        logger = Crest::CommonLogger.new(writer)
        logger.filter(/(access_token=)([^&]+)/, "\\1[REMOVED]")

        Crest::Request.get("#{TEST_SERVER_URL}/get", params: params, logger: logger, logging: true)

        date_time = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"
        url = "#{TEST_SERVER_URL}/get?width=100&height=100&access_token=[REMOVED]&v=2"

        reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} \\| .*GET.* \\| #{Regex.escape(url)}\\z"))
        reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} \\| .*200.* \\| #{Regex.escape(url)} \\| \".*\"\\z"))
      end
    end
  end

  describe "custom loggers" do
    it "applies filters when subclass logs through info" do
      IO.pipe do |reader, writer|
        params = {:width => "100", :access_token => "secret", :height => 100}
        logger = FilteredLogger.new(writer)

        Crest::Request.get("#{TEST_SERVER_URL}/get", params: params, logger: logger, logging: true)

        date_time = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}"
        url = "#{TEST_SERVER_URL}/get?width=100&access_token=[REMOVED]&height=100"

        reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} >> \\| GET \\| #{Regex.escape(url)}\\z"))
        reader.gets.should match(Regex.new("\\Acrest \\| #{date_time} << \\| 200 \\| #{Regex.escape(url)}\\z"))
      end
    end
  end
end
