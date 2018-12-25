require "../spec_helper"

describe Crest do
  describe "Streaming" do
    it "should stream Response#execute" do
      body = String::Builder.new
      request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/")

      request.execute do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Request.execute" do
      body = String::Builder.new
      Crest::Request.get("#{TEST_SERVER_URL}/") do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Request.get" do
      body = String::Builder.new
      Crest::Request.execute(:get, "#{TEST_SERVER_URL}/") do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Crest#get" do
      body = String::Builder.new
      Crest.get("#{TEST_SERVER_URL}/") do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Resource#get with []" do
      body = String::Builder.new
      resource = Crest::Resource.new(TEST_SERVER_URL)
      resource["/"].get do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Resource#get" do
      body = String::Builder.new
      resource = Crest::Resource.new(TEST_SERVER_URL)
      resource.get("/") do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Crest#get with redirects" do
      body = String::Builder.new

      Crest.get("#{TEST_SERVER_URL}/redirect/2") do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Response#execute with redirects" do
      body = String::Builder.new
      request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/redirect/2")

      request.execute do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end

    it "should stream Resource#get with redirects" do
      body = String::Builder.new
      resource = Crest::Resource.new(TEST_SERVER_URL)
      resource["/redirect/2"].get do |resp|
        while line = resp.body_io.gets
          body << line
        end
      end

      body.to_s.should eq("Hello World!")
    end
  end
end
