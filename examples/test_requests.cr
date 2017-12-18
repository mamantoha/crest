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
  logging: true
)

Crest.post(
  "http://httpbin.org/post",
  headers: {"Access-Token" => ["secret1", "secret2"]},
  payload: payload,
  logging: true,
  logger: MyLogger.new
)
