require "../src/crest"

class MyLogger < Crest::Logger
  def request(request)
    @logger.info ">> | %s | %s" % [request.method, request.url]
  end

  def response(response)
    @logger.info "<< | %s | %s" % [response.status_code, response.url]
  end
end

payload = {:fizz => "buz"}

Crest.get(
  "http://httpbin.org/get",
  headers: {"Access-Token" => ["secret1", "secret2"]},
  params: payload,
  logging: true,
  logger: MyLogger.new
)

Crest.post(
  "http://httpbin.org/post",
  headers: {"Access-Token" => ["secret1", "secret2"]},
  form: payload,
  logging: true,
)

begin
  Crest.get("http://httpbin.org/nonexistent")
rescue ex : Crest::NotFound
  puts ex.response
end

response = Crest.get("http://httpbin.org/nonexistent", handle_errors: false)
puts response.status_code

request = Crest::Request.new(:get, "http://httpbin.org/headers") do |req|
  req.headers.add("foo", "bar")
end

response = request.execute
puts response.body
