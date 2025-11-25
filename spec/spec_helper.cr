require "spec"
require "json"
require "http_proxy"
require "vcr"
require "../src/crest"
require "./support/constants"
require "./support/server"

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
