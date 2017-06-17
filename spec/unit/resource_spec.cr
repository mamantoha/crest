require "../spec_helper"

describe Crest::Resource do
  describe "#initialize" do
    it "initialize new resource" do
      resource = Crest::Resource.new("http://localhost", {"X-Something" => "1"})

      resource.url.should eq("http://localhost")
      resource.headers.should eq({"X-Something" => "1"})
    end

    it "initialize new resource without headers" do
      resource = Crest::Resource.new("http://localhost")

      resource.url.should eq("http://localhost")
      resource.headers.should eq({} of String => String)
    end

    it "initialize new resource with []" do
      site = Crest::Resource.new("http://localhost", {"X-Something" => "1"})
      resource = site["/resource"]

      resource.url.should eq("http://localhost/resource")
      resource.headers.should eq({"X-Something" => "1"})
    end

    # it "initialize new resource with params" do
    #   resource = Crest::Resource.new("http://localhost", params: {:foo => 123, :bar => "456"})
    #
    #   resource.url.should eq("http://localhost")
    #   resource.params.should eq({"foo" => "123", "bar" => "456"})
    # end
  end
end
