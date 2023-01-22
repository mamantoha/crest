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

      it "should get request headers" do
        response = Crest.get("#{TEST_SERVER_URL}/headers/set", params: {"foo" => "bar"})
        (response.status_code).should eq(200)
        (response.headers.[]("foo")).should eq("bar")
      end
    end
  end
end
