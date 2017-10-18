require "../spec_helper"

describe Crest do
  it "do GET request" do
    response = Crest.get("#{TEST_SERVER_URL}")
    (response.body).should eq("Hello World!")
  end

  it "do GET request with params" do
    response = Crest.get("#{TEST_SERVER_URL}/resize", params: {:width => 100, :height => 100})
    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with params with nil" do
    response = Crest.get("#{TEST_SERVER_URL}/add_key", params: {:json => nil, :key => 123})
    (response.body).should eq("JSON: key[123]")
  end

  it "do POST request" do
    response = Crest.post("#{TEST_SERVER_URL}/post/1/comments", payload: {:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "upload file" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest.post("#{TEST_SERVER_URL}/upload", payload: {:image1 => file})
    (response.body).should eq("Upload ok")
  end

  it "do POST nested params" do
    response = Crest.post("#{TEST_SERVER_URL}/post_nested", payload: {:params1 => "one", :nested => {:params2 => "two"}})
    (response.body).should eq("params1=one&nested%5Bparams2%5D=two")
  end

  it "do PUT request" do
    response = Crest.put("#{TEST_SERVER_URL}/post/1/comments/1", payload: {:title => "Put Update"})
    (response.body).should eq("Update Comment `1` for Post `1` with title `Put Update`")
  end

  it "do PATCH request" do
    response = Crest.patch("#{TEST_SERVER_URL}/post/1/comments/1", payload: {:title => "Patch Update"})
    (response.body).should eq("Update Comment `1` for Post `1` with title `Patch Update`")
  end

  it "do DELETE request" do
    response = Crest.delete("#{TEST_SERVER_URL}/post/1/comments/1")
    (response.body).should eq("Delete Comment `1` for Post `1`")
  end

  describe "Request" do
    it "do GET request" do
      response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/post/1/comments")

      (response.body).should eq("Post 1: comments")
    end

    it "do GET request with params" do
      response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/resize", params: {:width => 100, :height => 100})

      (response.body).should eq("Width: 100, height: 100")
    end

    it "do GET request with params with nil" do
      response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/add_key", params: {:json => nil, :key => 123})
      (response.body).should eq("JSON: key[123]")
    end

    it "do POST request" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post/1/comments", payload: {:title => "Title"})

      (response.body).should eq("Post with title `Title` created")
    end
  end

  describe "Resource" do
    it "do GET request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments", {"Content-Type" => "application/json"})
      response = resource.get
      (response.body).should eq("Post 1: comments")
    end

    it "do GET request with []" do
      site = Crest::Resource.new("#{TEST_SERVER_URL}", {"Content-Type" => "application/json"})
      response = site["/post/1/comments"].get
      (response.body).should eq("Post 1: comments")
    end

    it "do GET request with params" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/resize")
      response = resource.get(params: {:width => 100, :height => 100})
      (response.body).should eq("Width: 100, height: 100")
    end

    it "do POST request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
      response = resource.post({:title => "Title"})
      (response.body).should eq("Post with title `Title` created")
    end

    it "do POST request with []" do
      site = Crest::Resource.new(TEST_SERVER_URL)
      response = site["/post/1/comments"].post({:title => "Title"})
      (response.body).should eq("Post with title `Title` created")
    end

    # TODO: JSON
    # it "do POST JSON request" do
    #   params = {:title => "Title"}.to_json
    #   resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/json", {"Content-Type" => "application/json"})
    #   response = resource.post(params)
    #   (response.body).should eq("Post with title `Title` created")
    # end

    it "do PUT request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
      response = resource.put({:title => "Put Update"})
      (response.body).should eq("Update Comment `1` for Post `1` with title `Put Update`")
    end

    it "do PATCH request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
      response = resource.patch({:title => "Patch Update"})
      (response.body).should eq("Update Comment `1` for Post `1` with title `Patch Update`")
    end

    it "do DELETE request" do
      resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
      response = resource.delete
      (response.body).should eq("Delete Comment `1` for Post `1`")
    end
  end
end
