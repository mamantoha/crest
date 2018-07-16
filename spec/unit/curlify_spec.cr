require "../spec_helper"

def curlify(request : Crest::Request)
  Crest::Curlify.new(request).call
end

describe Crest::Curlify do
  it "converts simple GET request" do
    request = Crest::Request.new(:get, "http://localhost")

    result = "curl -X GET http://localhost"
    (request.to_curl).should eq(result)
  end

  it "converts GET request with params" do
    request = Crest::Request.new(:get, "http://localhost", params: {"foo" => "bar"})

    result = "curl -X GET http://localhost?foo=bar"
    curlify(request).should eq(result)
  end

  it "converts POST request" do
    request = Crest::Request.new(:post, "http://localhost", payload: {"param1" => "value1", "param2" => "value2"})

    result = "curl -X POST http://localhost -d 'param1=value1&param2=value2' -H 'Content-Type: multipart/form-data'"
    curlify(request).should eq(result)
  end

  it "converts POST request with headers" do
    request = Crest::Request.new(:post, "http://localhost", payload: {"param1" => "value1"}, headers: {"user-agent" => "crest"})

    result = "curl -X POST http://localhost -d 'param1=value1' -H 'user-agent: crest' -H 'Content-Type: multipart/form-data'"
    curlify(request).should eq(result)
  end

  it "converts POST request with json" do
    request = Crest::Request.new(:post, "http://localhost", payload: {:foo => "bar"}.to_json, headers: {"Content-Type" => "application/json"})

    result = "curl -X POST http://localhost -d '{\"foo\":\"bar\"}' -H 'Content-Type: application/json'"
    curlify(request).should eq(result)
  end
end
