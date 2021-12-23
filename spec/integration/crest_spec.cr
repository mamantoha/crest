require "../spec_helper"

describe Crest do
  it "do GET request" do
    response = Crest.get("#{TEST_SERVER_URL}")
    (response.body).should eq("200 OK")
  end

  it "do GET request with params" do
    response = Crest.get("#{TEST_SERVER_URL}/get", params: {:width => 100, :height => 100})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with different params" do
    response = Crest.get("#{TEST_SERVER_URL}/get", params: {"width" => 100, :height => "100"})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100"})
  end

  it "do GET request with nested params" do
    response = Crest.get("#{TEST_SERVER_URL}/get", params: {"width" => 100, "height" => 100, "image" => {"type" => "jpeg"}})

    body = JSON.parse(response.body)

    body["args"].should eq({"width" => "100", "height" => "100", "image[type]" => "jpeg"})
  end

  it "do GET request with params with nil" do
    response = Crest.get("#{TEST_SERVER_URL}/get", params: {:json => nil, :key => 123})

    body = JSON.parse(response.body)

    body["args"].should eq({"json" => "", "key" => "123"})
  end

  it "do POST request with form" do
    response = Crest.post("#{TEST_SERVER_URL}/post", {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with form" do
    response = Crest.post("#{TEST_SERVER_URL}/post", form: {:title => "Title"})

    body = JSON.parse(response.body)

    body["form"].should eq({"title" => "Title"})
  end

  it "do POST request with json" do
    response = Crest.post("#{TEST_SERVER_URL}/post", {"user" => {"name" => "John"}}, json: true)

    body = JSON.parse(response.body)

    body["json"].should eq({"user" => {"name" => "John"}})
  end

  it "upload file" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest.post("#{TEST_SERVER_URL}/upload", {:file => file})
    (response.body).should match(/Upload OK/)
  end

  it "upload file with form" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest.post("#{TEST_SERVER_URL}/upload", form: {:file => file})
    (response.body).should match(/Upload OK/)
  end

  it "upload file with nested form" do
    file = File.open("#{__DIR__}/../support/fff.png")
    response = Crest.post("#{TEST_SERVER_URL}/upload_nested", form: {:user => {:file => file}})
    (response.body).should match(/Upload OK/)
  end

  it "do POST with nested form" do
    response = Crest.post("#{TEST_SERVER_URL}/post", form: {:params1 => "one", :nested => {:params2 => "two"}})

    body = JSON.parse(response.body)

    body["form"].should eq({"params1" => "one", "nested[params2]" => "two"})
  end

  it "do PUT request with form" do
    response = Crest.put("#{TEST_SERVER_URL}/put", params: {"id" => 1}, form: {:title => "Put Update"})

    body = JSON.parse(response.body)

    body["method"].should eq("PUT")
    body["path"].should eq("/put?id=1")
    body["form"].should eq({"title" => "Put Update"})
  end

  it "do PATCH request with form" do
    response = Crest.patch("#{TEST_SERVER_URL}/patch", params: {"id" => 1}, form: {:title => "Patch Update"})

    body = JSON.parse(response.body)

    body["method"].should eq("PATCH")
    body["path"].should eq("/patch?id=1")
    body["form"].should eq({"title" => "Patch Update"})
  end

  it "do DELETE request" do
    response = Crest.delete("#{TEST_SERVER_URL}/delete", params: {"id" => 1})

    body = JSON.parse(response.body)

    body["method"].should eq("DELETE")
    body["path"].should eq("/delete?id=1")
  end

  it "do GET request with block without handle errors" do
    body = ""

    Crest.get("#{TEST_SERVER_URL}/404", handle_errors: false) do |resp|
      case resp
      when .success?
        body = resp.body_io.gets_to_end
      when .client_error?
        body = "Client error"
      when .server_error?
        body = "Server error"
      else
        raise "Unknown response with code #{resp.status_code}"
      end
    end

    body.should eq("Client error")
  end

  context ".to_curl" do
    it "curlify GET request with params" do
      response = Crest.get("#{TEST_SERVER_URL}/get", params: {:width => 100, :height => 100})
      (response.to_curl).should eq("curl -X GET #{TEST_SERVER_URL}/get?width=100&height=100")
    end

    it "curlify POST request with form" do
      response = Crest.post("#{TEST_SERVER_URL}/post", {:title => "Title"})
      (response.to_curl).should eq(
        "curl -X POST #{TEST_SERVER_URL}/post -d 'title=Title' -H 'Content-Type: application/x-www-form-urlencoded'"
      )
    end

    it "curlify POST request with file" do
      file = File.open("#{__DIR__}/../support/fff.png")
      response = Crest.post("#{TEST_SERVER_URL}/upload", form: {:file => file})

      (response.body).should match(/Upload OK/)
      (response.to_curl).should eq(
        "curl -X POST #{TEST_SERVER_URL}/upload -F 'file=@#{File.expand_path(file.path)}' -H 'Content-Type: multipart/form-data'"
      )
    end

    it "curlify POST request with json" do
      response = Crest.post(
        "#{TEST_SERVER_URL}/post",
        {:age => 27, :name => {:first => "Kurt", :last => "Cobain"}},
        json: true
      )

      body = JSON.parse(response.body)

      body["json"].should eq({"age" => 27, "name" => {"first" => "Kurt", "last" => "Cobain"}})

      (response.to_curl).should eq(
        "curl -X POST #{TEST_SERVER_URL}/post -d '{\"age\":27,\"name\":{\"first\":\"Kurt\",\"last\":\"Cobain\"}}' -H 'Content-Type: application/json'"
      )
    end
  end

  context "user_agent" do
    it "set default user agent" do
      response = Crest.get("#{TEST_SERVER_URL}/user-agent")
      (response.body).should eq(Crest::USER_AGENT)
    end

    it "set user agent form headers" do
      response = Crest.get("#{TEST_SERVER_URL}/user-agent", headers: {"User-Agent" => "Crest"})
      (response.body).should eq("Crest")
    end

    it "set custom user agent" do
      response = Crest.get("#{TEST_SERVER_URL}/user-agent", user_agent: "Crest")
      (response.body).should eq("Crest")
    end

    it "set custom user agent even if headers" do
      response = Crest.get("#{TEST_SERVER_URL}/user-agent", user_agent: "Crest", headers: {"User-Agent" => "Crest-headers"})
      (response.body).should eq("Crest")
    end
  end
end
