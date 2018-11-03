require "kemal"
require "./kemal_basic_auth"

class BasicAuthHandler < KemalBasicAuth::Handler
  only ["/secret", "/secret_redirect"]

  def call(env)
    return call_next(env) unless only_match?(env)

    super
  end
end

add_handler BasicAuthHandler.new("username", "password")

get "/" do
  "Hello World!"
end

options "/" do |env|
  env.response.headers["Allow"] = "OPTIONS, GET"
end

get "/secret" do
  "Secret World!"
end

get "/secret_redirect" do |env|
  env.redirect("/secret")
end

post "/upload" do |env|
  file = nil
  name = nil

  HTTP::FormData.parse(env.request) do |part|
    case part.name
    when "name"
      name = part.body.gets_to_end
    when "file"
      file = File.tempfile("upload") do |f|
        IO.copy(part.body, f)
      end
    end
  end

  if file
    "Upload OK - #{file.path}"
  end
end

post "/post_nested" do |env|
  params = env.params
  params.body.to_s
end

# Comments
#
# index
get "/post/:id/comments" do |env|
  "Post #{env.params.url["id"]}: comments"
end

# create
post "/post/:id/comments" do |env|
  "Post with title `#{env.params.body["title"]}` created"
end

# update
put "/post/:post_id/comments/:id" do |env|
  "Update Comment `#{env.params.url["id"]}` for Post `#{env.params.url["post_id"]}` with title `#{env.params.body["title"]}`"
end

# update
patch "/post/:post_id/comments/:id" do |env|
  "Update Comment `#{env.params.url["id"]}` for Post `#{env.params.url["post_id"]}` with title `#{env.params.body["title"]}`"
end

# delete
delete "/post/:post_id/comments/:id" do |env|
  "Delete Comment `#{env.params.url["id"]}` for Post `#{env.params.url["post_id"]}`"
end
###

# Matches /resize?width=200&height=200
get "/resize" do |env|
  width = env.params.query["width"]
  height = env.params.query["height"]

  "Width: #{width}, height: #{height}"
end

# Matches /resize?api_key=secter
post "/resize" do |env|
  height = env.params.body.[]("height")
  width = env.params.body.[]("width")
  key = env.params.query["key"]
  secret = env.params.query["secret"]

  "Width: #{width}, height: #{height}. Key: #{key}, secret: #{secret}"
end

# Matches /add_key?json&key=123
get "/add_key" do |env|
  key = env.params.query["key"]

  "JSON: key[#{key}]"
end

# TODO: JSON
post "/post/:id/json" do |env|
  title = env.params.json["title"].as(String)
  "Post with title `#{title}` created"
end

get "/404" do |env|
  env.response.status_code = 404
end

get "/500" do |env|
  env.response.status_code = 500
end

# Redirects
#
get "/redirect/1" do |env|
  env.redirect("/")
end

get "/redirect/2" do |env|
  env.redirect("/redirect/1")
end

get "/redirect/circle1" do |env|
  env.redirect("/redirect/circle2")
end

get "/redirect/circle2" do |env|
  env.redirect("/redirect/circle1")
end

get "/redirect/not_found" do |env|
  env.redirect("/404")
end

# Return request headers
get "/headers" do |env|
  result = {} of String => String
  env.request.headers.each do |key, value|
    result[key] = value.join(";")
  end

  {"headers" => result}.to_json
end

# Set response headers
get "/headers/set" do |env|
  env.params.query.each do |param|
    env.response.headers[param[0]] = param[1]
  end

  ""
end

# Returns cookies data
get "/cookies" do |env|
  result = {} of String => String
  env.request.cookies.to_h.each do |_, cookie|
    result[cookie.name] = cookie.value
  end

  {"cookies" => result}.to_json
end

# /cookies/set?name=value Sets one or more simple cookies.
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

# /cookies/set_redirect?name=value Sets one or more simple cookies and redirect.
get "/cookies/set_redirect" do |env|
  env.params.query.each do |param|
    env.response.cookies << HTTP::Cookie.new(name: param[0], value: param[1])
  end

  env.redirect("/cookies")
end

# Delays responding for `:seconds` seconds.
get "/delay/:seconds" do |env|
  seconds = env.params.url["seconds"].to_i
  sleep seconds

  "Delay #{seconds} seconds"
end

Kemal.run
