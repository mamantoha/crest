require "../crest"

user = ENV["GITHUB_USER"]
key = ENV["GITHUB_KEY"]

client = Crest::Resource.new(
  "https://api.github.com",
  user: user,
  password: key,
  logging: true,
)

response = client["/search/repositories?q=language=Crystal"].get
puts response.body
