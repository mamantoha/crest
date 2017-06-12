require "../spec_helper"

describe Crest do
  it "do GET request" do
    response = Crest.get("#{TEST_SERVER_URL}")
    (response.body).should eq("Hello World!")
  end

  it "upload file" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest.post("#{TEST_SERVER_URL}/upload", payload: {:image1 => file})
    (response.body).should eq("Upload ok")
  end

  it "do POST nested params" do
    response = Crest.post("#{TEST_SERVER_URL}/post_nested", payload: {:params1 => "one", :nested => {:params2 => "two"}})
    (response.body).should eq("params1=one&nested%5Bparams2%5D=two")
  end

  describe "Resource" do
    it "do GET request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}", {"Content-Type" => "application/json"})
      response = resource.get({"X-Something" => "1"})
    end
  end
end
