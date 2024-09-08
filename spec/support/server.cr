require "http/server"
require "json"
require "crypto/subtle"

def render_response(context : HTTP::Server::Context)
  args = context.request.query_params.to_h
  method = context.request.method

  raw_params = {} of String => Array(String)

  context.request.form_params.each do |key, value|
    if raw_params.has_key?(key)
      raw_params[key] << value
    else
      raw_params[key] = [value]
    end
  end

  form = {} of String => String | Array(String)

  raw_params.each do |key, value|
    if value.size == 1
      form[key] = value.first
    else
      form[key] = value
    end
  end

  json =
    begin
      if body = context.request.body
        JSON.parse(body.gets_to_end)
      else
        JSON.parse("{}")
      end
    rescue
      JSON.parse("{}")
    end

  headers = {} of String => String
  context.request.headers.each do |key, value|
    headers[key] = value.join(";")
  end

  cookies = {} of String => String
  context.request.cookies.to_h.each do |_, cookie|
    cookies[cookie.name] = cookie.value
  end

  {
    "args"    => args,
    "form"    => form,
    "json"    => json,
    "headers" => headers,
    "cookies" => cookies,
    "method"  => method,
    "path"    => context.request.resource,
  }.to_json
end

class HTTP::BasicAuthHandler
  include HTTP::Handler

  BASIC                 = "Basic"
  AUTH                  = "Authorization"
  AUTH_MESSAGE          = "Could not verify your access level for that URL.\nYou have to login with proper credentials"
  HEADER_LOGIN_REQUIRED = "Basic realm=\"Login Required\""
  PROTECTED_PATHS       = ["/secret"]

  def initialize(@username : String, @password : String)
  end

  def call(context) : Nil
    return call_next(context) unless PROTECTED_PATHS.includes?(context.request.path)

    if value = context.request.headers[AUTH]?
      if value.starts_with?(BASIC)
        return call_next(context) if authorize?(value)
      end
    end

    context.response.status_code = 401
    context.response.headers["WWW-Authenticate"] = HEADER_LOGIN_REQUIRED
    context.response.print AUTH_MESSAGE
  end

  private def authorize?(value : String) : Bool
    given_username, given_password = Base64.decode_string(value[BASIC.size + 1..-1]).split(":")

    return false unless Crypto::Subtle.constant_time_compare(@username, given_username)
    return false unless Crypto::Subtle.constant_time_compare(@password, given_password)

    true
  end
end

server = HTTP::Server.new([HTTP::BasicAuthHandler.new("username", "password")]) do |context|
  case context.request.path
  when "/"
    case context.request.method
    when "GET"
      context.response.print "200 OK"
    when "OPTIONS"
      context.response.headers["Allow"] = "OPTIONS, GET"
    end
  when "/get"
    context.response.print render_response(context)
  when "/post"
    context.response.print render_response(context)
  when "/put"
    context.response.print render_response(context)
  when "/patch"
    context.response.print render_response(context)
  when "/delete"
    context.response.print render_response(context)
  when "/foo/bar"
    context.response.print render_response(context)
  when "/404"
    context.response.respond_with_status(:not_found, "404 error")
  when "/500"
    context.response.respond_with_status(:internal_server_error)
  when "/secret"
    context.response.print "Authorized"
  when "/redirect_to_secret"
    context.response.redirect("/secret")
  when "/upload"
    request_content_type = context.request.headers["Content-Type"]

    file = nil

    if request_content_type.starts_with?("multipart/form-data")
      HTTP::FormData.parse(context.request) do |part|
        file = File.tempfile("upload") do |f|
          IO.copy(part.body, f)
        end
      end
    else
      suffix = MIME.extensions(request_content_type).first? || ""

      file = File.tempfile(suffix: suffix) do |f|
        context.request.body.try { |body| IO.copy(body, f) }
      end
    end

    unless file
      context.response.respond_with_status(:bad_request)
      next
    end

    context.response.print "Upload OK - #{file.path}"
  when "/upload_nested"
    file = nil

    HTTP::FormData.parse(context.request) do |part|
      file = File.tempfile("upload") do |f|
        IO.copy(part.body, f)
      end
    end

    unless file
      context.response.respond_with_status(:bad_request)
      next
    end

    context.response.print "Upload OK - #{file.path}"
  when "/user-agent"
    context.response.print context.request.headers["User-Agent"]
  when "/redirect/1"
    context.response.redirect("/")
  when "/redirect/2"
    context.response.redirect("/redirect/1")
  when "/redirect/circle1"
    context.response.redirect("/redirect/circle2")
  when "/redirect/circle2"
    context.response.redirect("/redirect/circle1")
  when "/redirect/not_found"
    context.response.redirect("/404")
  when "/headers/set"
    context.request.query_params.each do |key, value|
      context.response.headers[key] = value
    end

    context.response.print ""
  when "/cookies/set"
    context.request.query_params.each do |key, value|
      context.response.cookies << HTTP::Cookie.new(name: key, value: value)
    end

    result = {} of String => String
    context.response.cookies.to_h.each do |_, cookie|
      result[cookie.name] = cookie.value
    end

    context.response.print({"cookies" => result}.to_json)
  when "/cookies/set_redirect"
    context.request.query_params.each do |key, value|
      context.response.cookies << HTTP::Cookie.new(name: key, value: value)
    end

    context.response.redirect("/get")
  when /^\/delay\/(\d+)$/
    seconds = $1.to_i

    sleep seconds.seconds

    context.response.print "Delay #{seconds} seconds"
  when /^\/stream\/(\d+)$/
    count = $1.to_i

    count.times do
      context.response.puts("200 OK")
    end

    context.response
  when /^\/redirect_stream\/(\d+)$/
    count = $1.to_i

    context.response.redirect("/stream/#{count}")
  when "/download"
    filename = context.request.query_params["filename"]? || "foo.bar"
    file_path = "#{__DIR__}/fff.png"

    filesize = File.size(file_path)

    File.open(file_path) do |f|
      disposition = "attachment"

      context.response.headers["Content-Disposition"] = "#{disposition}; filename=\"#{File.basename(filename)}\""
      context.response.content_length = filesize

      IO.copy(f, context.response)
    end
  end
end

address = server.bind_tcp TEST_SERVER_HOST, TEST_SERVER_PORT
puts "Listening on http://#{address}"

spawn do
  server.listen
end
