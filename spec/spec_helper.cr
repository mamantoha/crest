require "spec"
require "json"
require "http_proxy"
require "../src/crest"

TEST_SERVER_URL = "http://127.0.0.1:4567"

def with_proxy_server(host = "127.0.0.1", port = 8080)
  wants_close = Channel(Nil).new
  server = HTTP::Proxy::Server.new(host, port)

  spawn do
    server.bind_tcp(port)
    server.listen
  end

  spawn do
    wants_close.receive
    server.close
  end

  Fiber.yield

  yield host, port, wants_close
end
