require "../spec_helper"

describe Crest::Response do
  it "do GET request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
    response = resource.get
    (response.body).should eq("Post 1: comments")
  end

  it "should not close connection after request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
    resource.get
    (resource.closed?).should be_falsey
  end

  it "do GET request when base url ends with /" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/")
    response = resource.get("/post/1/comments")
    (response.body).should eq("Post 1: comments")
  end

  it "do GET request when path does not start with /" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = resource.get("post/1/comments")
    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with []" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = site["/post/1/comments"].get
    (response.body).should eq("Post 1: comments")
  end

  it "do GET request with [] when base url ends with /" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}/")
    response = site["/post/1/comments"].get
    (response.body).should eq("Post 1: comments")
  end

  it "do multiple GET requests with []" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}")

    response1 = site["/post/1/comments"].get
    response2 = site["/post/2/comments"].get

    (response1.body).should eq("Post 1: comments")
    (response2.body).should eq("Post 2: comments")
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

  it "do GET request with suburl and params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource.get("resize", params: {:width => 100, :height => 100})
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

  it "do GET request with suburl and default params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {:width => 100}
    )
    response = resource.get("/resize", params: {:height => 100})
    (response.body).should eq("Width: 100, height: 100")
  end

  it "do GET request with suburl and default nested params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {"image" => {"type" => "jpeg"}}
    )
    response = resource.get("/resize", params: {"width" => "100", "height" => "100"})
    (response.body).should eq("Width: 100, height: 100, type: jpeg")
  end

  it "do GET request with [] and nested params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    params = {"width" => "100", "height" => "100", "image" => {"type" => "jpeg"}}

    response = resource["/resize"].get(params: params)

    (response.body).should eq("Width: 100, height: 100, type: jpeg")
  end

  it "do GET request with default cookies" do
    resource = Crest::Resource.new(TEST_SERVER_URL, cookies: {"k1" => "v1", "k2" => "v2"})
    response = resource["/"].get

    (response.status_code).should eq(200)
    (response.cookies).should eq({"k1" => "v1", "k2" => "v2"})
  end

  it "do GET request with default nested cookies" do
    resource = Crest::Resource.new(TEST_SERVER_URL, cookies: {"k1" => {"kk1" => "v1"}})
    response = resource["/"].get

    (response.status_code).should eq(200)
    (response.cookies).should eq({"k1[kk1]" => "v1"})
  end

  it "do GET request with cookies" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource["/"].get(cookies: {"k1" => "v1"})

    (response.status_code).should eq(200)
    (response.cookies).should eq({"k1" => "v1"})
  end

  it "do GET request with cookies and default cookies" do
    resource = Crest::Resource.new(TEST_SERVER_URL, cookies: {"k1" => "v1", "k2" => "v2"})
    response = resource["/"].get(cookies: {"k2" => "vv2"})

    (response.status_code).should eq(200)
    (response.cookies).should eq({"k1" => "v1", "k2" => "vv2"})
  end

  it "should accept block" do
    resource = Crest::Resource.new(TEST_SERVER_URL) do |res|
      res.headers.merge!({"foo" => "bar"})
    end

    response = resource["/headers"].get

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "initializer can accept HTTP::Client as http_client" do
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.before_request(&.headers.add("foo", "bar"))

    resource = Crest::Resource.new(TEST_SERVER_URL, http_client: client)
    response = resource["/headers"].get

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "access http_client in instance of Crest::Resource" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    resource.http_client.before_request(&.headers.add("foo", "bar"))

    response = resource["/headers"].get

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "change HTTP::Client in Crest::Resource" do
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.read_timeout = 5.minutes

    resource = Crest::Resource.new(TEST_SERVER_URL, http_client: client)

    resource.http_client.read_timeout = 1.second

    expect_raises IO::TimeoutError do
      resource["/delay/2"].get
    end
  end

  it "do POST request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
    response = resource.post({:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with form" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments")
    response = resource.post(form: {:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with []" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post/1/comments"].post({:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with [] and form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post/1/comments"].post(form: {:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with suburl" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site.post("/post/1/comments", {:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with suburl and form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site.post("/post/1/comments", form: {:title => "Title"})
    (response.body).should eq("Post with title `Title` created")
  end

  it "do POST request with [] and default params" do
    site = Crest::Resource.new(TEST_SERVER_URL, params: {"key" => "key"})
    response = site["/resize"].post(
      form: {:height => 100, "width" => "100"},
      params: {:secret => "secret"}
    )
    (response.body).should eq("Width: 100, height: 100. Key: key, secret: secret")
  end

  it "do POST request with [] and nested form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post_nested"].post(
      form: {:params1 => "one", :nested => {:params2 => "two"}}
    )

    (response.body).should eq("params1=one&nested%5Bparams2%5D=two")
  end

  it "do POST request with [] and json" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}", json: true)
    response = resource["/json"].post({"user" => {"name" => "John"}})

    (response.body).should eq("{\"user\":{\"name\":\"John\"}}")
  end

  it "upload file" do
    file = File.open("#{__DIR__}/../support/fff.png")
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/upload")
    response = resource.post(form: {:file => file})

    (response.body).should match(/Upload OK/)
  end

  it "upload file with []" do
    file = File.open("#{__DIR__}/../support/fff.png")
    resource = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = resource["/upload"].post(form: {:file => file})

    (response.body).should match(/Upload OK/)
  end

  it "do PUT request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
    response = resource.put(form: {:title => "Put Update"})
    (response.body).should eq("Update Comment `1` for Post `1` with title `Put Update`")
  end

  it "do PATCH request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
    response = resource.patch(form: {:title => "Patch Update"})
    (response.body).should eq("Update Comment `1` for Post `1` with title `Patch Update`")
  end

  it "do DELETE request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post/1/comments/1")
    response = resource.delete
    (response.body).should eq("Delete Comment `1` for Post `1`")
  end

  it "do GET request with logging" do
    IO.pipe do |r, w|
      logger = Crest::CommonLogger.new(w)

      resource = Crest::Resource.new(TEST_SERVER_URL, logger: logger, logging: true)
      response = resource["/post/1/comments"].get
      (response.body).should eq("Post 1: comments")

      r.gets.should match(/GET/)
      r.gets.should match(/200/)
    end
  end

  it "do OPTIONS request" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource.options

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end

  it "#to_curl" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = resource["/post/1/comments"].get

    (response.to_curl).should eq("curl -X GET #{TEST_SERVER_URL}/post/1/comments")
  end

  context "user_agent" do
    it "set user agent" do
      resource = Crest::Resource.new(TEST_SERVER_URL, user_agent: "Crest")
      response = resource["/user-agent"].get

      (response.body).should eq("Crest")
    end
  end
end
