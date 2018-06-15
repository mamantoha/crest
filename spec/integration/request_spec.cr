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

  it "call get method" do
    response = Crest::Request.get("#{TEST_SERVER_URL}/post/1/comments")

    (response.body).should eq("Post 1: comments")
  end

  it "call get method with block" do
    response = Crest::Request.get("#{TEST_SERVER_URL}/headers") do |request|
      request.headers.add("foo", "bar")
    end

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
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

  it "should accept block" do
    url = "#{TEST_SERVER_URL}/headers"

    request = Crest::Request.new(:get, url) do |req|
      req.headers.add("foo", "bar")
    end

    response = request.execute

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "initializer can accept HTTP::Client as http_client" do
    url = "#{TEST_SERVER_URL}/headers"
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.before_request do |request|
      request.headers.add("foo", "bar")
    end

    response = Crest::Request.execute(:get, url, http_client: client)
    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "access http_client in instance of Crest::Request" do
    url = "#{TEST_SERVER_URL}/headers"

    request = Crest::Request.new(:get, url)

    request.http_client.before_request do |req|
      req.headers.add("foo", "bar")
    end

    response = request.execute

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "change HTTP::Client in Crest::Request" do
    url = "#{TEST_SERVER_URL}/delay/2"
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.read_timeout = 5.minutes

    request = Crest::Request.new(:get, url, http_client: client)

    request.http_client.read_timeout = 1.second

    expect_raises IO::Timeout do
      request.execute
    end
  end

  it "do POST request" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post/1/comments", payload: {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "call post method" do
    response = Crest::Request.post("#{TEST_SERVER_URL}/post/1/comments", payload: {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "do OPTIONS request" do
    response = Crest::Request.execute(:options, "#{TEST_SERVER_URL}")

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end

  it "call options method" do
    response = Crest::Request.options("#{TEST_SERVER_URL}")

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end
end
