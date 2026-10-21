require "../spec_helper"

describe "Digest authentication" do
  it "keeps credentials out of both request targets" do
    requests = [] of HTTP::Request
    server = HTTP::Server.new do |context|
      requests << context.request

      if requests.size == 1
        context.response.status_code = 401
        context.response.headers["WWW-Authenticate"] = %(Digest realm="test", nonce="test-nonce", algorithm=MD5)
      else
        context.response.print "Authorized"
      end
    end
    address = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    response = Crest.get(
      "http://#{address}/private?key=value",
      auth: "digest",
      user: "username",
      password: "password"
    )

    response.body.should eq("Authorized")
    requests.map(&.resource).should eq(["/private?key=value", "/private?key=value"])
    requests.first.headers.has_key?("Authorization").should be_false

    ha1 = Digest::MD5.hexdigest("username:test:password")
    ha2 = Digest::MD5.hexdigest("GET:/private?key=value")
    digest = Digest::MD5.hexdigest("#{ha1}:test-nonce:#{ha2}")
    authorization = requests.last.headers["Authorization"]
    authorization.should start_with("Digest ")
    authorization.should contain(%(response="#{digest}"))
  ensure
    server.try &.close
  end
end
