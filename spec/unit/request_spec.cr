require "../spec_helper"

describe Crest::Request do
  describe "#initialize" do
    it "new Request with default arguments" do
      request = Crest::Request.new(:get, "http://localhost")
      (request.url).should eq("http://localhost")
      (request.max_redirects).should eq(10)
      (request.user).should be_nil
      (request.password).should be_nil
      (request.proxy).should be_nil
      (request.logging).should be_false
    end

    it "initialize the GET request" do
      request = Crest::Request.new(:get, "http://localhost", headers: {"Content-Type" => "application/json"})
      (request.method).should eq("GET")
      (request.url).should eq("http://localhost")
      (request.headers).should eq(HTTP::Headers{"Content-Type" => "application/json"})
      (request.form_data).should eq(nil)
    end

    it "initialize the GET request with params" do
      request = Crest::Request.new(:get, "http://localhost", params: {:foo => "123", :bar => 456})
      (request.method).should eq("GET")
      (request.url).should eq("http://localhost?foo=123&bar=456")
      (request.form_data).should eq(nil)
    end

    it "initialize the GET request with params in url" do
      request = Crest::Request.new(:get, "http://localhost?json", params: {:key => 123})
      (request.method).should eq("GET")
      (request.url).should eq("http://localhost?json&key=123")
      (request.form_data).should eq(nil)
    end

    it "initialize the GET request with nil value in params" do
      request = Crest::Request.new(:get, "http://localhost", params: {:json => nil, :key => 123})
      (request.method).should eq("GET")
      (request.url).should eq("http://localhost?json&key=123")
      (request.form_data).should eq(nil)
    end

    it "initialize the GET request with cookies" do
      request = Crest::Request.new(:get, "http://localhost", cookies: {:foo => "123", :bar => 456})
      (request.headers).should eq(HTTP::Headers{"Cookie" => "foo=123; bar=456"})
    end

    it "initialize the POST request with payload" do
      request = Crest::Request.new(:post, "http://localhost", headers: {"Content-Type" => "application/json"}, payload: {:foo => "bar"})
      (request.method).should eq("POST")
      (request.url).should eq("http://localhost")
      (request.headers["Content-Type"]).should contain("application/json,multipart/form-data; boundary=")
      (request.form_data.to_s).should contain("Content-Disposition: form-data; name=\"foo\"\r\n\r\nbar\r\n")
    end

    it "initialize the POST request with payload as a string" do
      request = Crest::Request.new(:post, "http://localhost", headers: {"Content-Type" => "application/json"}, payload: {:foo => "bar"}.to_json)
      (request.method).should eq("POST")
      (request.url).should eq("http://localhost")
      (request.headers["Content-Type"]).should eq("application/json")
      (request.form_data.to_s).should eq("{\"foo\":\"bar\"}")
    end

    it "POST request with nested hashes" do
      request = Crest::Request.new(:post, "http://localhost", headers: {"Content-Type" => "application/json"}, payload: {:params1 => "one", :nested => {:params2 => "two"}})
      (request.headers["Content-Type"]).should contain("application/json,multipart/form-data; boundary=")
      (request.form_data.to_s).should contain("form-data; name=\"nested[params2]\"")
    end

    it "initialize the PUT request with payload" do
      request = Crest::Request.new(:put, "http://localhost", headers: {"Content-Type" => "application/json"}, payload: {:foo => "bar"})
      (request.method).should eq("PUT")
      (request.url).should eq("http://localhost")
      (request.headers["Content-Type"]).should contain("application/json,multipart/form-data; boundary=")
      (request.form_data.to_s).should contain("Content-Disposition: form-data; name=\"foo\"\r\n\r\nbar\r\n")
    end

    it "initialize the OPTIONS request" do
      request = Crest::Request.new(:options, "http://localhost")
      (request.method).should eq("OPTIONS")
      (request.url).should eq("http://localhost")
    end

    it "initialize Request with :max_redirects" do
      request = Crest::Request.new(:get, "http://localhost", max_redirects: 3)
      (request.max_redirects).should eq(3)
    end

    it "initialize Request with basic auth params" do
      request = Crest::Request.new(:get, "http://localhost", user: "user", password: "password")
      (request.user).should eq("user")
      (request.password).should eq("password")
    end

    it "initialize Request with proxy params" do
      request = Crest::Request.new(:get, "http://localhost", p_addr: "localhost", p_port: 3128)
      (request.proxy).should be_a(HTTP::Proxy::Client)
    end

    it "initialize Request with :logging and logger" do
      request = Crest::Request.new(:get, "http://localhost", logging: true)
      (request.logging).should eq(true)
      (request.logger).should be_a(Crest::Logger)
    end
  end
end
