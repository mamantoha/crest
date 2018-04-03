require "../spec_helper"

describe Crest::Request do
  it "initialize and do request" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/post/1/comments")
    response = request.execute

    (response.body).should eq("Post 1: comments")
  end

  it "do GET request" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/post/1/comments")

    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with params" do
    response = Crest::Request.execute(:get,
      "#{TEST_SERVER_URL}/resize",
      params: {:width => 100, :height => 100}
    )

    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with different params" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/resize", params: {"width" => 100, :height => "100"})

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

  it "do OPTIONS request" do
    response = Crest::Request.execute(:options, "#{TEST_SERVER_URL}")

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end
end
