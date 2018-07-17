require "../spec_helper"

def curlify(request : Crest::Request)
  Crest::Curlify.new(request).call
end

describe Crest::Curlify do
  it "converts simple GET request" do
    request = Crest::Request.new(:get, "http://httpbin.org/get")

    result = "curl -X GET http://httpbin.org/get"
    (request.to_curl).should eq(result)
  end

  it "converts GET request with params" do
    request = Crest::Request.new(:get, "http://httpbin.org/get", params: {"foo" => "bar"})

    result = "curl -X GET http://httpbin.org/get?foo=bar"
    curlify(request).should eq(result)
  end

  it "converts POST request" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"param1" => "value1", "param2" => "value2"})

    result = "curl -X POST http://httpbin.org/post -d 'param1=value1&param2=value2' -H 'Content-Type: application/x-www-form-urlencoded'"
    curlify(request).should eq(result)
  end

  it "converts POST request with multipart" do
    file = File.open("#{__DIR__}/../support/fff.png")
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"param1" => "value1", "file" => file})

    result = "curl -X POST http://httpbin.org/post -F 'param1=value1' -F 'file=@#{"#{__DIR__}/../support/fff.png"}' -H 'Content-Type: multipart/form-data'"
    curlify(request).should eq(result)
  end

  it "converts POST request with headers" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"param1" => "value1"}, headers: {"user-agent" => "crest"})

    result = "curl -X POST http://httpbin.org/post -d 'param1=value1' -H 'user-agent: crest' -H 'Content-Type: application/x-www-form-urlencoded'"
    curlify(request).should eq(result)
  end

  it "converts POST request with json" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {:foo => "bar"}.to_json, headers: {"Content-Type" => "application/json"})

    result = "curl -X POST http://httpbin.org/post -d '{\"foo\":\"bar\"}' -H 'Content-Type: application/json'"

    curlify(request).should eq(result)
  end
end
