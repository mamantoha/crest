require "../spec_helper"

describe Crest::Request do
  it "initialize and do request" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/get")
    response = request.execute

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "should close connection after request by default" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/get")
    request.execute

    (request.closed?).should be_truthy
  end

  it "should not close connection after request if close_connetion is false" do
    request = Crest::Request.new(:get, "#{TEST_SERVER_URL}/get", close_connection: false)
    request.execute

    (request.closed?).should be_falsey
  end

  it "do GET request" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/get")

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "call get method" do
    response = Crest::Request.get("#{TEST_SERVER_URL}/get")

    body = JSON.parse(response.body)

    body["path"].should eq("/get")
  end

  it "do GET request with params" do
    response = Crest::Request.execute(:get,
      "#{TEST_SERVER_URL}/get",
      params: {:width => 100, :height => 1455494400}
    )

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "1455494400"})
  end

  it "do GET request with nested params" do
    response = Crest::Request.execute(:get,
      "#{TEST_SERVER_URL}/get",
      params: {:width => 100, :height => 100, :image => {:type => "jpeg"}}
    )

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100", "image[type]" => "jpeg"})
  end

  it "do GET request with different params" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/get", params: {"width" => 100, :height => "100"})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with params with nil" do
    response = Crest::Request.execute(:get, "#{TEST_SERVER_URL}/get", params: {:json => nil, :key => 123})

    body = JSON.parse(response.body)

    body["args"].should eq({"json" => "", "key" => "123"})
  end

  it "should accept block on initialize as request" do
    url = "#{TEST_SERVER_URL}/get"

    request = Crest::Request.new(:get, url, &.headers.add("foo", "bar"))

    response = request.execute

    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "initializer can accept HTTP::Client as http_client" do
    url = "#{TEST_SERVER_URL}/get"
    uri = URI.parse(TEST_SERVER_URL)

    client = HTTP::Client.new(uri)
    client.before_request(&.headers.add("foo", "bar"))

    response = Crest::Request.execute(:get, url, http_client: client)
    (JSON.parse(response.body)["headers"]["foo"]).should eq("bar")
  end

  it "access http_client in instance of Crest::Request" do
    url = "#{TEST_SERVER_URL}/get"

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

  it "sets read_timeout for HTTP::Client" do
    url = "#{TEST_SERVER_URL}/delay/2"
    request = Crest::Request.new(:get, url, read_timeout: 1.second)

    expect_raises IO::TimeoutError do
      request.execute
    end
  end

  it "do POST request" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with form" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request and encode form" do
    response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", form: {:title => "New @Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "New @Title"})
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

  it "do POST request with form with Float" do
    request = Crest::Request.new(
      :post,
      "#{TEST_SERVER_URL}/post",
      {"latitude" => 49.553516, "longitude" => 25.594767}
    )
    response = request.execute

    body = JSON.parse(response.body)

    body["form"].should eq({"latitude" => "49.553516", "longitude" => "25.594767"})
  end

  it "call .post method" do
    response = Crest::Request.post("#{TEST_SERVER_URL}/post", {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "call .post method with form" do
    response = Crest::Request.post("#{TEST_SERVER_URL}/post", form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
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

  it "call .post method with form and json with Float" do
    request = Crest::Request.new(
      :post,
      "#{TEST_SERVER_URL}/post",
      {"latitude" => 49.553516, "longitude" => 25.594767},
      json: true
    )
    response = request.execute

    body = JSON.parse(response.body)

    body["json"].should eq({"latitude" => 49.553516, "longitude" => 25.594767})
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
    body = response.body
    (body).should match(/Upload OK/)
    file_path = body.gsub("Upload OK - ", "")
    (File.read(file_path)).should eq(File.read(file.path))
  end

  it "upload file directly" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest::Request.post("#{TEST_SERVER_URL}/upload", form: file, headers: {"Content-Type" => "image/png"})
    body = response.body
    (body).should match(/Upload OK/)
    file_path = body.gsub("Upload OK - ", "")
    (file_path.ends_with?(".png")).should be_true
    (File.read(file_path)).should eq(File.read(file.path))
  end

  it "upload IO::Memory directly" do
    file_content = "{\"foo\":\"bar\"}"
    file = IO::Memory.new(file_content)
    response = Crest::Request.post("#{TEST_SERVER_URL}/upload", form: file, headers: {"Content-Type" => "application/json"})
    body = response.body
    (body).should match(/Upload OK/)
    file_path = body.gsub("Upload OK - ", "")
    (file_path.ends_with?(".json")).should be_true
    (File.read(file_path)).should eq(file_content)
  end

  it "upload IO::Memory as form hash value" do
    file_content = "{\"foo\":\"bar\"}"
    file = IO::Memory.new(file_content)
    request = Crest::Request.new(:POST, "#{TEST_SERVER_URL}/upload", form: {"file.json" => file})
    (request.form_data.to_s).should contain("Content-Type: application/json")
    response = request.execute
    body = response.body
    (body).should match(/Upload OK/)
    file_path = body.gsub("Upload OK - ", "")
    (File.read(file_path)).should eq(file_content)
  end

  it "upload Bytes directly" do
    file_content = "{\"foo\":\"bar\"}"
    file = file_content.to_slice
    response = Crest::Request.post("#{TEST_SERVER_URL}/upload", form: file, headers: {"Content-Type" => "application/json"})
    body = response.body
    (body).should match(/Upload OK/)
    file_path = body.gsub("Upload OK - ", "")
    (file_path.ends_with?(".json")).should be_true
    (File.read(file_path)).should eq(file_content)
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
      "#{TEST_SERVER_URL}/post",
      headers: {"Content-Type" => "application/json"},
      form: {:title => "Title"}
    )

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  describe "request headers" do
    it "POST request with form" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", {"user" => {"name" => "John"}})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("*/*")
      (json["headers"]["Content-Type"]).should eq("application/x-www-form-urlencoded")
    end

    it "POST request with multipart form" do
      file = File.open("#{__DIR__}/../support/fff.png")

      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", {"file" => file})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("*/*")
      (json["headers"]["Content-Type"].to_s).should match(/multipart\/form-data; boundary/)
    end

    it "POST request with json" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", {"user" => {"name" => "John"}}, json: true)

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("application/json")
      (json["headers"]["Content-Type"]).should eq("application/json")
    end

    it "POST request with Accept header" do
      response = Crest::Request.execute(:post, "#{TEST_SERVER_URL}/post", {"foo" => "bar"}, headers: {"Accept" => "application/pdf"})

      json = JSON.parse(response.body)

      (json["headers"]["Accept"]).should eq("application/pdf")
    end
  end

  describe "User-Agent" do
    it "should have default user agent" do
      url = "#{TEST_SERVER_URL}/get"

      request = Crest::Request.new(:get, url)

      response = request.execute

      (JSON.parse(response.body)["headers"]["User-Agent"]).should eq("Crest/#{Crest::VERSION} (Crystal/#{Crystal::VERSION})")
    end

    it "change user agent" do
      url = "#{TEST_SERVER_URL}/get"

      request = Crest::Request.new(:get, url, headers: {"User-Agent" => "Crest"})

      response = request.execute

      (JSON.parse(response.body)["headers"]["User-Agent"]).should eq("Crest")
    end
  end
end
