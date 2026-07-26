require "spec"
require "json"
require "http_proxy"
require "vcr"
require "../src/crest"
require "./support/constants"
require "./support/server"

def with_proxy_server(host = PROXY_SERVER_HOST, port = 0, &)
  wants_close = Channel(Nil).new
  started = Channel(Socket::IPAddress | Exception).new(1)
  server = HTTP::Proxy::Server.new

  spawn do
    address =
      begin
        server.bind_tcp(host, port)
      rescue ex
        started.send(ex)
        next
      end

    started.send(address)
    server.listen
  end

  spawn do
    wants_close.receive
    server.close
  end

  address = started.receive
  raise address if address.is_a?(Exception)

  yield host, address.port, wants_close
end
