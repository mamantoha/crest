require "../spec_helper"

describe Crest::Response do
  it "do GET request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/get")
    response = resource.get

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "should not close connection after request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/get")
    resource.get
    (resource.closed?).should be_falsey
  end

  it "do GET request when base url ends with /" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/")
    response = resource.get("/get")

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "do GET request when path does not start with /" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = resource.get("get")

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "do GET request with nested path" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/foo")
    response = resource.get("bar")

    body = JSON.parse(response.body)

    body["path"].should eq("/foo/bar")
  end

  it "do GET request with []" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = site["/get"].get

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "do GET request with [] when base url ends with /" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}/")
    response = site["/get"].get

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "do multiple GET requests with []" do
    site = Crest::Resource.new("#{TEST_SERVER_URL}")

    response1 = site["/get?id=1"].get
    response2 = site["/get?id=2"].get

    body1 = JSON.parse(response1.body)
    body2 = JSON.parse(response2.body)

    body1["path"].should eq("/get?id=1")
    body2["path"].should eq("/get?id=2")
  end

  it "do GET request with params" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/get")
    response = resource.get(params: {:width => "100", :height => 100})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with [] and params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource["/get"].get(params: {:width => 100, :height => 100})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with suburl and params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource.get("get", params: {:width => 100, :height => 100})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with [] and default params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {:width => 100, :height => 100}
    )
    response = resource["/get"].get

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with suburl and default params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {:width => 100}
    )
    response = resource.get("/get", params: {:height => 100})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with suburl and default nested params" do
    resource = Crest::Resource.new(
      TEST_SERVER_URL,
      params: {"image" => {"type" => "jpeg"}}
    )
    response = resource.get("/get", params: {"width" => "100", "height" => "100"})

    body = JSON.parse(response.body)

    body["args"].should eq({"image[type]" => "jpeg", "width" => "100", "height" => "100"})
  end

  it "do GET request with [] and nested params" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    params = {"width" => "100", "height" => "100", "image" => {"type" => "jpeg"}}

    response = resource["/get"].get(params: params)

    body = JSON.parse(response.body)

    body["args"].should eq({"image[type]" => "jpeg", "width" => "100", "height" => "100"})
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

    response = resource["/get"].get

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "initializer can accept HTTP::Client as http_client" do
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.before_request(&.headers.add("foo", "bar"))

    resource = Crest::Resource.new(TEST_SERVER_URL, http_client: client)
    response = resource["/get"].get

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "access http_client in instance of Crest::Resource" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    resource.http_client.before_request(&.headers.add("foo", "bar"))

    response = resource["/get"].get

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
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post")
    response = resource.post({:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with form" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/post")
    response = resource.post(form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with []" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post"].post({:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with [] and form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post"].post(form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with suburl" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site.post("/post", {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with suburl and form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site.post("/post", form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with [] and default params" do
    site = Crest::Resource.new(TEST_SERVER_URL, params: {"key" => "key"})
    response = site["/post"].post(
      form: {:height => 100, "width" => "100"},
      params: {:secret => "secret"}
    )

    body = JSON.parse(response.body)

    body["args"].should eq({"key" => "key", "secret" => "secret"})
    body["form"].should eq({"width" => "100", "height" => "100"})
  end

  it "do POST request with [] and nested form" do
    site = Crest::Resource.new(TEST_SERVER_URL)
    response = site["/post"].post(
      form: {:params1 => "one", :nested => {:params2 => "two"}}
    )

    body = JSON.parse(response.body)

    body["form"].should eq({"params1" => "one", "nested[params2]" => "two"})
    body["json"].should eq({} of JSON::Any => JSON::Any)
  end

  it "do POST request with [] and json" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}", json: true)
    response = resource["/post"].post({"user" => {"name" => "John"}})

    body = JSON.parse(response.body)

    body["json"].should eq({"user" => {"name" => "John"}})
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
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/put")
    response = resource.put(form: {:title => "Put Update"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Put Update"})
  end

  it "do PATCH request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/patch")
    response = resource.patch(form: {:title => "Patch Update"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Patch Update"})
  end

  it "do DELETE request" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}/delete")
    response = resource.delete

    body = JSON.parse(response.body)

    body["method"].should eq("DELETE")
  end

  it "do GET request with logging" do
    IO.pipe do |reader, writer|
      logger = Crest::CommonLogger.new(writer)

      resource = Crest::Resource.new(TEST_SERVER_URL, logger: logger, logging: true)
      resource["/get"].get

      reader.gets.should match(/GET/)
      reader.gets.should match(/200/)
    end
  end

  it "do OPTIONS request" do
    resource = Crest::Resource.new(TEST_SERVER_URL)
    response = resource.options

    (response.headers["Allow"]).should eq("OPTIONS, GET")
  end

  context "params_encoder" do
    describe Crest::NestedParamsEncoder do
      it "do POST request" do
        resource = Crest::Resource.new("#{TEST_SERVER_URL}", params_encoder: Crest::NestedParamsEncoder)
        response = resource["/post"].post({"size" => "small", "topping" => ["bacon", "onion"]})

        body = JSON.parse(response.body)

        body["form"].should eq({"size" => "small", "topping" => ["bacon", "onion"]})
      end
    end
  end

  it "#to_curl" do
    resource = Crest::Resource.new("#{TEST_SERVER_URL}")
    response = resource["/get"].get

    (response.to_curl).should eq("curl -X GET #{TEST_SERVER_URL}/get")
  end

  context "user_agent" do
    it "set user agent" do
      resource = Crest::Resource.new(TEST_SERVER_URL, user_agent: "Crest")
      response = resource["/user-agent"].get

      (response.body).should eq("Crest")
    end
  end

  context "read_timeout" do
    it "sets read timeout" do
      resource = Crest::Resource.new(TEST_SERVER_URL, read_timeout: 1.seconds)

      expect_raises IO::TimeoutError do
        resource["/delay/2"].get
      end
    end
  end
end
