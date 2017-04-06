require "kemal"

get "/" do
  "Hello World!"
end

post "/upload" do |env|
  file = env.params.files["image1"]
  "Upload ok"
end

Kemal.run
