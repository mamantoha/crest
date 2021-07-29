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

  it "converts a request with digest auth as parameters" do
    request = Crest::Request.new(:get, "http://httpbin.org/digest-auth/auth/user/passwd/MD5", auth: "digest", user: "user", password: "passwd")

    result = "curl -X GET http://httpbin.org/digest-auth/auth/user/passwd/MD5 --digest --user user:passwd"
    (request.to_curl).should eq(result)
  end

  it "converts a request to invalid domain with digest auth" do
    request = Crest::Request.new(:get, "https://domain.invalid", auth: "digest", user: "user", password: "passwd")

    result = "curl -X GET https://domain.invalid --digest --user user:passwd"
    (request.to_curl).should eq(result)
  end

  it "converts a request with basic auth in headers" do
    request = Crest::Request.new(:get, "http://httpbin.org/basic-auth/user/passwd", headers: {"Authorization" => "Basic dXNlcjpwYXNzd2Q="})

    result = "curl -X GET http://httpbin.org/basic-auth/user/passwd -H 'Authorization: Basic dXNlcjpwYXNzd2Q='"
    (request.to_curl).should eq(result)
  end

  it "converts a request with proxy" do
    request = Crest::Request.new(:get, "http://httpbin.org", p_addr: "127.0.0.1", p_port: 8080)

    result = "curl -X GET http://httpbin.org --proxy 127.0.0.1:8080"
    (request.to_curl).should eq(result)
  end

  it "converts a request with proxy with authentication" do
    request = Crest::Request.new(:get, "http://httpbin.org", p_addr: "127.0.0.1", p_port: 8080, p_user: "user", p_pass: "pass")

    result = "curl -X GET http://httpbin.org --proxy user:pass@127.0.0.1:8080"
    (request.to_curl).should eq(result)
  end

  it "converts a request with cookies" do
    request = Crest::Request.new(:get, "http://httpbin.org/get", cookies: {"k1" => "v1", "k2" => {"kk2" => "vv2"}})

    result = "curl -X GET http://httpbin.org/get -H 'Cookie: k1=v1; k2[kk2]=vv2'"
    (request.to_curl).should eq(result)
  end

  it "converts POST request" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"title" => "New Title", "author" => "admin"})

    result = "curl -X POST http://httpbin.org/post -d 'title=New+Title&author=admin' -H 'Content-Type: application/x-www-form-urlencoded'"
    curlify(request).should eq(result)
  end

  it "converts POST request with multipart" do
    file = File.open("#{__DIR__}/../support/fff.png")

    request = Crest::Request.new(:post, "http://httpbin.org/post", form: {"title" => "New Title", "file" => file})

    result = "curl -X POST http://httpbin.org/post -F 'title=New Title' -F 'file=@#{"#{File.expand_path(file.path)}"}' -H 'Content-Type: multipart/form-data'"
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

  it "converts POST request with json" do
    request = Crest::Request.new(:post, "http://httpbin.org/post", {:foo => "bar"}, json: true)

    result = "curl -X POST http://httpbin.org/post -d '{\"foo\":\"bar\"}' -H 'Content-Type: application/json'"

    curlify(request).should eq(result)
  end

  it "converts request with user_agent" do
    request = Crest::Request.new(:get, "http://httpbin.org/get", user_agent: "Crest")

    result = "curl -X GET http://httpbin.org/get -H 'User-Agent: Crest'"

    curlify(request).should eq(result)
  end
end
