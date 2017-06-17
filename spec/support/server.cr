require "kemal"

get "/" do
  "Hello World!"
end

post "/upload" do |env|
  file = env.params.files["image1"]
  "Upload ok"
end

post "/post_nested" do |env|
  params = env.params
  params.body
end

get "/post/:id/comments" do |env|
  "Post #{env.params.url["id"]}: comments"
end

post "/post/:id/comments" do |env|
  "Post with title `#{env.params.body["title"]}` created"
end

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

Kemal.run
