require "../spec_helper"

describe Crest::Request do
  it "initialize and do request" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/post/1/comments")
    response = request.execute

    (response.body).should eq("Post 1: comments")
  end

  it "should close connection after request by default" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/post/1/comments")
    request.execute

    (request.http_client.closed?).should be_truthy
  end

  it "should not close connection after request if close_connetion is false" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/post/1/comments", close_connection: false)
    request.execute

    (request.http_client.closed?).should be_falsey
  end

  it "do GET request" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/post/1/comments")

    (response.body).should eq("Post 1: comments")
  end

  it "call get method" do
    response = Crest::Request.get("#{TEST_SERVER_URL}/post/1/comments")

    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with params" do
    response = Crest::Request.execute(:get,
      "#{TEST_SERVER_URL}/resize",
      params: {:width => 100, :height => 1455494400}
    )

    (response.body).should eq("Width: 100, height: 1455494400")
  end

  it "do GET request with nested params" do
    response = Crest::Request.execute(:get,
      "#{TEST_SERVER_URL}/resize",
      params: {:width => 100, :height => 100, :image => {:type => "jpeg"}}
    )

    (response.body).should eq("Width: 100, height: 100, type: jpeg")
  end

  it "do GET request with different params" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/resize", params: {"width" => 100, :height => "100"})

    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with params with nil" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/add_key", params: {:json => nil, :key => 123})
    (response.body).should eq("JSON: key[123]")
  end

  it "should accept block on initialize as request" do
    url = "#{TEST_SERVER_URL}/headers"

    request = Crest::Request.new(:get, url, &.headers.add("foo", "bar"))

    response = request.execute

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "initializer can accept HTTP::Client as http_client" do
    url = "#{TEST_SERVER_URL}/headers"
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.before_request(&.headers.add("foo", "bar"))

    response = Crest::Request.execute(:get, url, http_client: client)
    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "access http_client in instance of Crest::Request" do
    url = "#{TEST_SERVER_URL}/headers"

    request = Crest::Request.new(:get, url)

    request.http_client.before_request(&.headers.add("foo", "bar"))

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

    expect_raises IO::TimeoutError do
      request.execute
    end
  end

  it "do POST request" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post/1/comments", {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with form" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post/1/comments", form: {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request and encode form" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post/1/comments", form: {:title => "New @Title"})

    (response.body).should eq("Post with title `New @Title` created")
  end

  it "do POST request with form with Int64" do
    request = Crest::Request.new(
      :post,
      "#{TEST_SERVER_URL}/post",
      {"user" => {"name" => "John", "time" => Time.utc(2016, 2, 15).to_unix}}
    )
    response = request.execute

    body = JSON.parse(response.body)

    body["form"].should eq({"user[name]" => "John", "user[time]" => "1455494400"})
  end

  it "call .post method" do
    response = Crest::Request.post("#{TEST_SERVER_URL}/post/1/comments", {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "call .post method with form" do
    response = Crest::Request.post("#{TEST_SERVER_URL}/post/1/comments", form: {:title => "Title"})

    (response.body).should eq("Post with title `Title` created")
  end

  it "call .post method with form and json" do
    request = Crest::Request.new(:post, "#{TEST_SERVER_URL}/post", {"user" => {"name" => "John"}}, json: true)
    response = request.execute

    body = JSON.parse(response.body)

    body["json"].should eq({"user" => {"name" => "John"}})
  end

  it "call .post method with form and json with Int64" do
    request = Crest::Request.new(
      :post,
      "#{TEST_SERVER_URL}/post",
      {"user" => {"name" => "John", "time" => Time.utc(2016, 2, 15).to_unix}},
      json: true
    )
    response = request.execute

    body = JSON.parse(response.body)

    body["json"].should eq({"user" => {"name" => "John", "time" => 1455494400}})
  end

  it "call .post method with form and json string" do
    response = Crest::Request.post(
      "#{TEST_SERVER_URL}/post",
      {:title => "Title"}.to_json,
      headers: {"Content-Type" => "application/json"}
    )

    body = JSON.parse(response.body)

    body["json"].should eq({"title" => "Title"})
  end

  it "call .post method with form and json" do
    response = Crest::Request.post(
      "#{TEST_SERVER_URL}/post",
      headers: {"Content-Type" => "application/json"},
      form: {:title => "Title"}.to_json
    )

    body = JSON.parse(response.body)

    body["json"].should eq({"title" => "Title"})
  end

  it "upload file with form" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest::Request.post("#{TEST_SERVER_URL}/upload", form: {:file => file})
    (response.body).should match(/Upload OK/)
  end

  it "do OPTIONS request" do
    response = Crest::Request.execute(:options, "#{TEST_SERVER_URL}")

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end

  it "call options method" do
    response = Crest::Request.options("#{TEST_SERVER_URL}")

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end

  it "should skip 'Content-Type' in headers for requests with form" do
    response = Crest::Request.post(
      "#{TEST_SERVER_URL}/post/1/comments",
      headers: {"Content-Type" => "application/json"},
      form: {:title => "Title"}
    )

    (response.body).should eq("Post with title `Title` created")
  end

  describe "request headers" do
    it "POST request with form" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/headers", {"user" => {"name" => "John"}})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("*/*")
      (json["headers"]["Content-Type"]).should eq("application/x-www-form-urlencoded")
    end

    it "POST request with multipart form" do
      file = File.open("#{__DIR__}/../support/fff.png")

      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/headers", {"file" => file})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("*/*")
      (json["headers"]["Content-Type"].to_s).should match(/multipart\/form-data; boundary/)
    end

    it "POST request with json" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/headers", {"user" => {"name" => "John"}}, json: true)

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("application/json")
      (json["headers"]["Content-Type"]).should eq("application/json")
    end

    it "POST request with Accept header" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/headers", {"foo" => "bar"}, headers: {"Accept" => "application/pdf"})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("application/pdf")
    end
  end

  describe "User-Agent" do
    it "should have default user agent" do
      url = "#{TEST_SERVER_URL}/headers"

      request = Crest::Request.new(:get, url)

      response = request.execute

      (JSON.parse(response.body)["headers"]["User-Agent"]).should eq("Crest/#{Crest::VERSION} (Crystal/#{Crystal::VERSION})")
    end

    it "change user agent" do
      url = "#{TEST_SERVER_URL}/headers"

      request = Crest::Request.new(:get, url, headers: {"User-Agent" => "Crest"})

      response = request.execute

      (JSON.parse(response.body)["headers"]["User-Agent"]).should eq("Crest")
    end
  end
end
