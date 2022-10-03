# :nodoc:
class HTTP::Client
  def closed? : Bool
    @io ? false : true
  end

  private def exec_internal_single(request, implicit_compression = false)
    send_request(request)
    HTTP::Client::Response.from_io?(io, ignore_body: request.ignore_body?, decompress: implicit_compression)
  end
end
