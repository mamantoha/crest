require "../spec_helper"

describe Crest do
  describe "Raise exception" do
    it "404" do
      expect_raises Crest::RequestFailed, "HTTP status code 404" do
        Crest.get("#{TEST_SERVER_URL}/404")
      end
    end

    it "500" do
      expect_raises Crest::RequestFailed, "HTTP status code 500" do
        Crest.get("#{TEST_SERVER_URL}/500")
      end
    end

    it "call .response on the exception to get the server's response" do
      response =
        begin
          Crest.get("#{TEST_SERVER_URL}/404")
        rescue ex : Crest::RequestFailed
          ex.response
        end

      (response.status_code).should eq(404)
    end
  end
end
