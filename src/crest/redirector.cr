module Crest
  class Redirector
    def initialize(@response : Crest::Response, @request : Crest::Request)
    end

    def follow : Crest::Response
      case @response
      when .success?
        @response
      when .redirect?
        check_max_redirects

        @request.max_redirects > 0 ? follow_redirection : @response
      else
        raise_exception! if @request.handle_errors
        @response
      end
    end

    def follow(&block : Crest::Response ->)
      case @response
      when .success?
        @response
      when .redirect?
        check_max_redirects

        @request.max_redirects > 0 ? follow_redirection(&block) : @response
      else
        raise_exception! if @request.handle_errors
        @response
      end
    end

    private def check_max_redirects
      raise_exception! if @request.max_redirects <= 0 && @request.handle_errors
    end

    # Follow a redirection response by making a new HTTP request to the
    # redirection target.
    private def follow_redirection : Crest::Response
      new_request.execute
    end

    private def follow_redirection(&block : Crest::Response ->)
      new_request.execute(&block)
    end

    private def new_request
      new_request = prepare_new_request(resolved_redirect_uri.to_s)
      new_request.redirection_history = @response.history + [@response]

      @request.close

      new_request
    end

    private def prepare_new_request(url)
      Request.new(
        method: redirect_method,
        url: url,
        form: redirect_form_data,
        max_redirects: @request.max_redirects - 1,
        headers: redirect_headers,
        cookies: redirect_cookies,
        cookie_jar: @request.cookie_jar,
        params_encoder: @request.params_encoder,
        auth: redirect_auth,
        user: redirect_user,
        password: redirect_password,
        logging: @request.logging,
        logger: @request.logger,
        handle_errors: @request.handle_errors,
        p_addr: @request.p_addr,
        p_port: @request.p_port,
        p_user: @request.p_user,
        p_pass: @request.p_pass,
        json: @request.json,
        multipart: @request.multipart,
        user_agent: @request.user_agent,
        close_connection: @request.close_connection,
        tls: @request.tls,
        read_timeout: @request.read_timeout,
        write_timeout: @request.write_timeout,
        connect_timeout: @request.connect_timeout,
      )
    end

    private def redirect_cookies
      @request.cookie_jar ? ({} of String => String) : @response.cookies
    end

    private def redirect_auth : String
      preserve_credentials_on_redirect? ? @request.auth : "basic"
    end

    private def redirect_user : String?
      preserve_credentials_on_redirect? ? @request.user : nil
    end

    private def redirect_password : String?
      preserve_credentials_on_redirect? ? @request.password : nil
    end

    private def redirect_method : Symbol
      case @request.method
      when "DELETE"  then preserve_method_on_redirect? ? :delete : :get
      when "POST"    then preserve_method_on_redirect? ? :post : :get
      when "PUT"     then preserve_method_on_redirect? ? :put : :get
      when "PATCH"   then preserve_method_on_redirect? ? :patch : :get
      when "OPTIONS" then preserve_method_on_redirect? ? :options : :get
      when "HEAD"    then :head
      else                :get
      end
    end

    private def redirect_form_data
      preserve_body_on_redirect? ? @request.form_data : nil
    end

    private def preserve_method_on_redirect? : Bool
      case @response.status_code
      when 301
        @request.method != "POST"
      when 302, 303
        false
      when 307, 308
        true
      else
        false
      end
    end

    private def preserve_body_on_redirect? : Bool
      preserve_method_on_redirect? && !@request.form_data.nil?
    end

    private def redirect_headers
      headers = @request.headers.to_h.dup

      headers.delete("Authorization")
      headers.delete("Cookie")
      headers.delete("Host")
      headers.delete("Content-Length")
      headers.delete("Transfer-Encoding")

      unless preserve_body_on_redirect?
        headers.delete("Content-Type")
      end

      headers
    end

    private def preserve_credentials_on_redirect? : Bool
      redirect_uri = resolved_redirect_uri
      request_uri = URI.parse(@request.url)

      redirect_uri.scheme == request_uri.scheme &&
        redirect_uri.host == request_uri.host &&
        redirect_uri.port == request_uri.port
    end

    private def resolved_redirect_uri : URI
      URI.parse(@request.url).resolve(@response.http_client_res.headers["location"])
    end

    private def raise_exception!
      raise RequestFailed.subclass_by_status_code(@response.status_code).new(@response)
    end
  end
end
