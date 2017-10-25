require "http"
require "socket"
require "base64"

module HTTP
  # :nodoc:
 module Proxy
    # Represents a proxy client with all its attributes.
    # Provides convenient access and modification of them.
    class Client
      property host : String
      property port : Int32
      property username : String?
      property password : String?

      # Create a new socket factory that tunnels via the given host and  port.
      # The following optional arguments are supported:
      #
      # * :username - the user name to use when authenticating to the proxy
      # * :password - the password to use when authenticating
      def initialize(
                     @host : String,
                     @port = 80,
                     *,
                     @username : String?,
                     @password : String?)
      end

      # Return a new socket connected to the given host and port via the
      # proxy that was requested when the socket factory was instantiated.
      def open(host, port)
        socket = TCPSocket.new(@host, @port)
        socket.sync = true

        return socket
      end
    end
  end

  class Client
    def set_proxy(proxy : HTTP::Proxy::Client)
      @socket = proxy.open(host: proxy.host, port: proxy.port)
      if proxy.username
        proxy_basic_auth(proxy.username, proxy.password)
      end

      @socket
    end

    private def proxy_basic_auth(username : String?, password : String?)
      header = "Basic #{Base64.strict_encode("#{username}:#{password}")}"
      before_request do |request|
        request.headers["Proxy-Authorization"] = header
      end
    end
  end
end
