require "kemal"
require "kemal-basic-auth"

class BasicAuthHandler < Kemal::BasicAuth::Handler
  only ["/secret"]

  def call(env)
    return call_next(env) unless only_match?(env)

    super
  end
end

def render_response(env)
  args = env.params.query.to_h
  data = env.params.body.to_s
  json = env.params.json
  method = env.request.method

  raw_params = {} of String => Array(String)

  env.params.body.each do |key, value|
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

  headers = {} of String => String
  env.request.headers.each do |key, value|
    headers[key] = value.join(";")
  end

  cookies = {} of String => String
  env.request.cookies.to_h.each do |_, cookie|
    cookies[cookie.name] = cookie.value
  end

  env.response.content_type = "application/json"

  {
    "args"    => args,
    "data"    => data,
    "form"    => form,
    "json"    => json,
    "headers" => headers,
    "cookies" => cookies,
    "method"  => method,
    "path"    => env.request.resource,
  }.to_json
end

add_handler BasicAuthHandler.new("username", "password")

error 404 do
  "404 error"
end

error 500 do
  "500 error"
end

get "/" do
  "200 OK"
end

# Returns GET data.
get "/get" do |env|
  render_response(env)
end

# Returns request data. Allows only POST requests.
post "/post" do |env|
  render_response(env)
end

# Returns request data. Allows only PUT requests.
put "/put" do |env|
  render_response(env)
end

# Returns request data. Allows only PATCH requests.
patch "/patch" do |env|
  render_response(env)
end

# Returns request data. Allows only DELETE requests.
delete "/delete" do |env|
  render_response(env)
end

# HTML form that submits to /post
get "/forms/post" do |_env|
  render "#{__DIR__}/views/forms/post.ecr"
end

options "/" do |env|
  env.response.headers["Allow"] = "OPTIONS, GET"
end

get "/secret" do
  "Authorized"
end

get("/redirect_to_secret", &.redirect("/secret"))

post "/upload" do |env|
  request_content_type = env.request.headers["Content-Type"]

  file =
    if request_content_type.starts_with?("multipart/form-data")
      env.params.files.values.first.tempfile
    else
      File.tempfile(suffix: MIME.extensions(request_content_type).first) do |f|
        env.request.body.try { |body| IO.copy(body, f) }
      end
    end

  "Upload OK - #{file.path}"
end

post "/upload_nested" do |env|
  file = env.params.files["user[file]"].tempfile

  "Upload OK - #{file.path}"
end

get "/user-agent" do |env|
  env.request.headers["User-Agent"]
end

# Errors
#
get("/404", &.response.status_code=(404))

get("/500", &.response.status_code=(500))

# Stream
#
get "/stream/:count" do |env|
  count = env.params.url["count"].to_i

  count.times do
    env.response.puts("200 OK")
  end

  env
end

# Redirects
#
get "/redirect/1" do |env|
  env.redirect("/", body: "Redirecting to /")
end

get("/redirect/2", &.redirect("/redirect/1"))

get "/redirect/circle1" do |env|
  env.redirect("/redirect/circle2")
end

get "/redirect/circle2" do |env|
  env.redirect("/redirect/circle1")
end

get("/redirect/not_found", &.redirect("/404"))

get "/redirect_stream/:count" do |env|
  count = env.params.url["count"].to_i

  env.redirect("/stream/#{count}")
end

# Set response headers.
# /headers/set?name=value
get "/headers/set" do |env|
  env.params.query.each do |param|
    env.response.headers[param[0]] = param[1]
  end

  ""
end

# Sets one or more simple cookies.
# /cookies/set?name=value
get "/cookies/set" do |env|
  env.params.query.each do |param|
    env.response.cookies << HTTP::Cookie.new(name: param[0], value: param[1])
  end

  result = {} of String => String
  env.response.cookies.to_h.each do |_, cookie|
    result[cookie.name] = cookie.value
  end

  {"cookies" => result}.to_json
end

# Delays responding for `:seconds` seconds.
get "/delay/:seconds" do |env|
  seconds = env.params.url["seconds"].to_i
  sleep seconds

  "Delay #{seconds} seconds"
end

# Matches /download?filename=foo.bar
get "/download" do |env|
  filename = env.params.query["filename"]? || "foo.bar"
  file = File.open("#{__DIR__}/fff.png")

  send_file env, file.path, mime_type: "Application/octet-stream", filename: filename
end
