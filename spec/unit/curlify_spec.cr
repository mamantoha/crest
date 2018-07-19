require "../spec_helper"

def curlify(request : Crest::Request)
  Crest::Curlify.new(request).to_curl
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

  it "converts a request with basic auth as parameters" do
    request = Crest::Request.new(:get, "http://httpbin.org/basic-auth/user/passwd", user: "user", password: "passwd")

    result = "curl -X GET http://httpbin.org/basic-auth/user/passwd --user user:passwd"
    (request.to_curl).should eq(result)
  end

  it "converts a request with basic auth in headers" do
    request = Crest::Request.new(:get, "http://httpbin.org/basic-auth/user/passwd", headers: {"Authorization" => "Basic dXNlcjpwYXNzd2Q="})

    result = "curl -X GET http://httpbin.org/basic-auth/user/passwd -H 'Authorization: Basic dXNlcjpwYXNzd2Q='"
    (request.to_curl).should eq(result)
  end

  it "converts POST request" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"title" => "New Title", "author" => "admin"})

    result = "curl -X POST http://httpbin.org/post -d 'title=New+Title&author=admin' -H 'Content-Type: application/x-www-form-urlencoded'"
    curlify(request).should eq(result)
  end

  it "converts POST request with multipart" do
    current_dir = __DIR__
    file = File.open("#{current_dir}/../support/fff.png")

    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"title" => "New Title", "file" => file})

    result = "curl -X POST http://httpbin.org/post -F 'title=New Title' -F 'file=@#{"#{current_dir}/../support/fff.png"}' -H 'Content-Type: multipart/form-data'"
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
