require "../spec_helper"

describe Crest::Redirector do
  describe Crest do
    it "should redirect" do
      response = Crest.get("#{TEST_SERVER_URL}/redirect/1")

      (response.status_code).should eq(200)
      (response.url).should eq("#{TEST_SERVER_URL}/")
      (response.body).should eq("200 OK")
      (response.history.size).should eq(1)
      (response.history.first.url).should eq("#{TEST_SERVER_URL}/redirect/1")
      (response.history.first.status_code).should eq(302)
    end

    it "should redirect and save history" do
      response = Crest.get("#{TEST_SERVER_URL}/redirect/2")

      (response.url).should eq("#{TEST_SERVER_URL}/")
      (response.status_code).should eq(200)
      (response.history.size).should eq(2)
      (response.history.first.status_code).should eq(302)
    end

    it "should redirect with logger" do
      IO.pipe do |reader, writer|
        logger = Crest::CommonLogger.new(writer)

        response = Crest.get("#{TEST_SERVER_URL}/redirect/1", logger: logger, logging: true)

        reader.gets.should match(/GET/)
        reader.gets.should match(/302/)
        reader.gets.should match(/GET/)
        reader.gets.should match(/200/)

        (response.request.logging).should eq(true)
        (response.request.logger).should be_a(Crest::Logger)
      end
    end

    it "should raise error when too many redirects" do
      expect_raises Crest::RequestFailed, "HTTP status code 302" do
        Crest.get("#{TEST_SERVER_URL}/redirect/circle1")
      end
    end

    it "should raise last error" do
      expect_raises Crest::RequestFailed, "HTTP status code 404" do
        Crest.get("#{TEST_SERVER_URL}/redirect/not_found")
      end
    end

    it "should not raise last error if handle_errors is false" do
      response = Crest.get("#{TEST_SERVER_URL}/redirect/not_found", handle_errors: false)

      (response.url).should eq("#{TEST_SERVER_URL}/404")
      (response.status_code).should eq(404)
      (response.history.first.status_code).should eq(302)
    end

    it "should not follow redirection when max_redirects is 0" do
      expect_raises Crest::RequestFailed, "HTTP status code 302" do
        Crest.get("#{TEST_SERVER_URL}/redirect/1", max_redirects: 0)
      end
    end

    it "should not follow redirection when max_redirects is 0 and raise Crest::Found" do
      expect_raises Crest::Found, "HTTP status code 302" do
        Crest.get("#{TEST_SERVER_URL}/redirect/1", max_redirects: 0)
      end
    end

    it "should not raise exception when handle_errors is false" do
      response = Crest.get("#{TEST_SERVER_URL}/redirect/1", max_redirects: 0, handle_errors: false)

      (response.url).should eq("#{TEST_SERVER_URL}/redirect/1")
      (response.status_code).should eq(302)
      (response.body).should eq("")
    end

    it "should not raise exception in the block when handle_errors is false" do
      body = status_code = nil

      Crest.get("#{TEST_SERVER_URL}/redirect/1", max_redirects: 0, handle_errors: false) do |response|
        status_code = response.status_code
        body = response.body_io.gets_to_end
      end

      body.should eq("")
      status_code.should eq(302)
    end
  end

  describe Crest::Request do
    it "should redirect" do
      request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/redirect/1")
      response = request.execute

      (response.status_code).should eq(200)
      (response.url).should eq("#{TEST_SERVER_URL}/")
      (response.body).should eq("200 OK")
      (response.history.size).should eq(1)
      (response.history.first.url).should eq("#{TEST_SERVER_URL}/redirect/1")
      (response.history.first.status_code).should eq(302)
    end
  end

  describe Crest::Resource do
    it "should redirect" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}")
      response = resource["/redirect/1"].get

      (response.status_code).should eq(200)
      (response.url).should eq("#{TEST_SERVER_URL}/")
      (response.body).should eq("200 OK")
      (response.history.size).should eq(1)
      (response.history.first.url).should eq("#{TEST_SERVER_URL}/redirect/1")
      (response.history.first.status_code).should eq(302)
    end
  end
end
