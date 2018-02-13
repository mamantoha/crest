require "../spec_helper"

describe Crest::Response do
  it "do GET request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
    response = resource.get
    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with []" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = site["/post/1/comments"].get
    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with params" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/resize")
    response = resource.get(params: {:width => "100", :height => 100})
    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with [] and params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource["/resize"].get(params: {:width => 100, :height => 100})
    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with [] and default params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {:width => 100, :height => 100}
    )
    response = resource["/resize"].get
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

  it "do POST request with [] and default params" do
    site = Crest::Resource.new(TEST_SERVER_URL, params: {"key" => "key"})
    response = site["/resize"].post(
      payload: {:height => 100, "width" => "100"},
      params: {:secret => "secret"}
    )
    (response.body).should eq("Width: 100, height: 100. Key: key, secret: secret")
  end

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

  it "do GET request with logging" do
    resource = Crest::Resource.new(TEST_SERVER_URL, logging: true)
    response = resource["/post/1/comments"].get
    (response.body).should eq("Post 1: comments")
  end
end
