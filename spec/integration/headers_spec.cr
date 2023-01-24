require "../spec_helper"

describe Crest do
  describe "Headers" do
    context Crest::Request do
      it "should set headers" do
        response = Crest.get("#{TEST_SERVER_URL}/get", headers: {"Access-Token" => ["secret1", "secret2"]})
        (response.status_code).should eq(200)
        (JSON.parse(response.body)["headers"]["Access-Token"]).should eq("secret1;secret2")
        response.headers.should_not contain("Access-Token")
      end

      it "should set headers in the block" do
        request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/get", headers: {"k1" => "v1"}) do |req|
          req.headers["k2"] = "v2"
        end

        response = request.execute

        (response.status_code).should eq(200)
        (JSON.parse(response.body)["headers"]["k1"]).should eq("v1")
        (JSON.parse(response.body)["headers"]["k2"]).should eq("v2")
      end

      it "should get request headers" do
        response = Crest.get("#{TEST_SERVER_URL}/headers/set", params: {"foo" => "bar"})
        (response.status_code).should eq(200)
        (response.headers.[]("foo")).should eq("bar")
      end
    end
  end
end
