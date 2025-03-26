require "spec"
require "json"
require "http_proxy"
require "vcr"
require "../src/crest"
require "./support/server"

TEST_SERVER_HOST  = "127.0.0.1"
TEST_SERVER_PORT  = 4567
TEST_SERVER_URL   = "http://#{TEST_SERVER_HOST}:#{TEST_SERVER_PORT}"
PROXY_SERVER_HOST = "127.0.0.1"
PROXY_SERVER_PORT = 8088

def with_proxy_server(host = PROXY_SERVER_HOST, port = PROXY_SERVER_PORT, &)
  wants_close = Channel(Nil).new
  server = HTTP::Proxy::Server.new

  spawn do
    server.bind_tcp(host, port)
    server.listen
  end

  spawn do
    wants_close.receive
    server.close
  end

  Fiber.yield

  yield host, port, wants_close
end
