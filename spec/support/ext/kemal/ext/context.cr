class HTTP::Server
  class Context
    def redirect(url : String, status_code : Int32 = 302, *, body : String = "")
      @response.headers.add "Location", url
      @response.write(body.to_slice)
      @response.status_code = status_code
    end
  end
end
