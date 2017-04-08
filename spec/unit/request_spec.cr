require "../spec_helper"

describe Crest::Request do
  describe "#initialize" do
    it "initialize the GET request" do
      request = Crest::Request.new(:get, "http://localhost", {"Content-Type" => "application/json"})
      (request.method).should eq("GET")
      (request.url).should eq("http://localhost")
      (request.headers).should eq(HTTP::Headers{"Content-Type" => "application/json"})
      (request.payload).should eq(nil)
    end

    it "initialize the POST request with payload" do
      request = Crest::Request.new(:post, "http://localhost", {"Content-Type" => "application/json"}, {:foo => "bar"})
      (request.method).should eq("POST")
      (request.url).should eq("http://localhost")
      (request.headers["Content-Type"]).should contain("application/json,multipart/form-data; boundary=")
      (request.payload.to_s).should contain("Content-Disposition: form-data; name=\"foo\"\r\n\r\nbar\r\n")
    end

    # it "POST request with nested hashes" do
    #   request = Crest::Request.new(:post, "http://localhost", {"Content-Type" => "application/json"}, {:params1 => "one", :nested => {:params2 => "two"}})
    #   (request.headers["Content-Type"]).should contain("application/json,multipart/form-data; boundary=")
    #   (request.payload.to_s).should contain("IDK")
    # end

  end
end
