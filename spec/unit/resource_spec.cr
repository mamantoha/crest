require "../spec_helper"

describe Crest::Resource do
  describe "#initialize" do
    it "initialize new resource" do
      resource = Crest::Resource.new("http://localhost", headers: {"X-Something" => "1"})

      resource.url.should eq("http://localhost")
      resource.headers.should eq({"X-Something" => "1"})
    end

    it "initialize new resource with proxy params" do
      resource = Crest::Resource.new("http://localhost", p_addr: "localhost", p_port: 3128)

      resource.p_addr.should eq("localhost")
      resource.p_port.should eq(3128)
    end

    it "initialize new resource with logger" do
      resource = Crest::Resource.new("http://localhost", logging: true)

      (resource.logging).should be_true
      (resource.logger).should be_a(Crest::Logger)
    end

    it "initialize new resource without headers" do
      resource = Crest::Resource.new("http://localhost")

      resource.url.should eq("http://localhost")
      resource.headers.should eq({} of String => String)
    end

    it "initialize new resource with []" do
      site = Crest::Resource.new("http://localhost", headers: {"X-Something" => "1"})
      resource = site["/resource"]

      resource.url.should eq("http://localhost/resource")
      resource.headers.should eq({"X-Something" => "1"})
      site.url.should eq("http://localhost")
    end

    it "initialize new resource with params" do
      resource = Crest::Resource.new("http://localhost", params: {"foo" => "123", "bar" => "456"})

      resource.url.should eq("http://localhost")
      resource.params.should eq({"foo" => "123", "bar" => "456"})
    end

    it "initialize new resource with cookie jar" do
      jar = HTTP::CookieJar.new
      resource = Crest::Resource.new("http://localhost", cookie_jar: jar)

      resource.cookie_jar.should be(jar)
    end

    it "returns independent subresources" do
      site = Crest::Resource.new("http://localhost", headers: {"X-Something" => "1"})
      resource = site["/resource"]

      resource.headers["X-Other"] = "2"

      site.headers.should eq({"X-Something" => "1"})
      resource.headers.should eq({"X-Something" => "1", "X-Other" => "2"})
    end

    it "preserves cookie jar on subresources" do
      jar = HTTP::CookieJar.new
      site = Crest::Resource.new("http://localhost", cookie_jar: jar)
      resource = site["/resource"]

      resource.cookie_jar.should be(jar)
    end
  end
end
