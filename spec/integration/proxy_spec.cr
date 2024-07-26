require "../spec_helper"

describe Crest do
  describe "With proxy server" do
    it "should make request" do
      with_proxy_server do |host, port, wants_close|
        load_cassette("httpbingo.org") do
          response = Crest.get("https://httpbingo.org/get", p_addr: host, p_port: port, user_agent: "Crest")
          (response.status_code).should eq(200)
        end
      ensure
        wants_close.send(nil)
      end
    end

    it "should redirect with proxy" do
      with_proxy_server do |host, port, wants_close|
        load_cassette("httpbingo.org") do
          response = Crest.get("https://httpbingo.org/redirect/1", p_addr: host, p_port: port, user_agent: "Crest")
          (response.status_code).should eq(200)
          (response.url).should eq("https://httpbingo.org/get")
          (response.history.size).should eq(1)
          (response.history.first.url).should eq("https://httpbingo.org/redirect/1")
          (response.history.first.status_code).should eq(302)
        end
      ensure
        wants_close.send(nil)
      end
    end
  end

  describe Crest::Request do
    it "should make request" do
      with_proxy_server do |host, port, wants_close|
        load_cassette("httpbingo.org") do
          request = Crest::Request.new(:get, "https://httpbingo.org/get", p_addr: host, p_port: port, user_agent: "Crest")
          response = request.execute

          (response.status_code).should eq(200)
          (response.body.chomp).should eq("{}")
        end
      ensure
        wants_close.send(nil)
      end
    end
  end

  describe Crest::Resource do
    it "should make request" do
      with_proxy_server do |host, port, wants_close|
        load_cassette("httpbingo.org") do
          resource = Crest::Resource.new("https://httpbingo.org/get", p_addr: host, p_port: port, user_agent: "Crest")
          response = resource.get

          (response.status_code).should eq(200)
        end
      ensure
        wants_close.send(nil)
      end
    end

    it "should make suburl request" do
      with_proxy_server do |host, port, wants_close|
        load_cassette("httpbingo.org") do
          resource = Crest::Resource.new("https://httpbingo.org/", p_addr: host, p_port: port, user_agent: "Crest")
          response = resource["/get"].get

          (response.status_code).should eq(200)
        end
      ensure
        wants_close.send(nil)
      end
    end
  end
end
