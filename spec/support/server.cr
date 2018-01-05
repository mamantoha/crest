require "kemal"
require "./kemal_basic_auth"

class BasicAuthHandler < KemalBasicAuth::Handler
  only ["/secret", "secret_redirect"]

  def call(env)
    return call_next(env) unless only_match?(env)

    super
  end
end

add_handler BasicAuthHandler.new("username", "password")

get "/" do
  "Hello World!"
end

get "/secret" do |env|
  "Secret World!"
end

get "/secret_redirect" do |env|
  env.redirect("/secret")
end

post "/upload" do |env|
  file = env.params.files["image1"]
  "Upload ok"
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

# Matches /add_key?json&key=123
get "/add_key" do |env|
  key = env.params.query["key"]

  "JSON: key[#{key}]"
end

# TODO: JSON
post "/post/:id/json" do |env|
  title = env.params.json["title"].as(String)
  "Post with title `#{env.params.json["title"]}` created"
end

get "/404" do |env|
  env.response.status_code = 404
end

get "/500" do |env|
  env.response.status_code = 500
end

# Redirect
#
get "/redirect" do |env|
  env.redirect("/")
end

get "/redirect/circle1" do |env|
  env.redirect("/redirect/circle2")
end

get "/redirect/circle2" do |env|
  env.redirect("/redirect/circle1")
end

# Returns header dict.
get "/headers" do |env|
  result = {} of String => String
  env.request.headers.each do |key, value|
    result[key] = value.join(";")
  end

  {"headers" => result}.to_json
end

# Returns cookie data
get "/cookies" do |env|
  result = {} of String => String
  env.request.cookies.to_h.each do |str, cookie|
    result[cookie.name] = cookie.value
  end

  {"cookies" => result}.to_json
end

# /cookies/set?name=value Sets one or more simple cookies.
get "/cookies/set" do |env|
  env.params.query.each do |param|
    puts param
    env.response.cookies << HTTP::Cookie.new(name: param[0], value: param[1])
  end

  result = {} of String => String
  env.response.cookies.to_h.each do |str, cookie|
    result[cookie.name] = cookie.value
  end

  {"cookies" => result}.to_json
end

# /cookies/set_redirect?name=value Sets one or more simple cookies and redirect.
get "/cookies/set_redirect" do |env|
  env.params.query.each do |param|
    puts param
    env.response.cookies << HTTP::Cookie.new(name: param[0], value: param[1])
  end

  env.redirect("/cookies")
end

Kemal.run
