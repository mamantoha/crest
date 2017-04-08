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

Kemal.run
