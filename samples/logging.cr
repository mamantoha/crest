require "../src/crest"

class MyLogger < Crest::Logger
  def request(request) : Nil
    @logger.info { ">> | %s | %s" % [request.method, request.url] }
  end

  def response(response) : Nil
    @logger.info { "<< | %s | %s" % [response.status_code, response.url] }
  end
end

Crest.get("http://httpbin.org/get", logging: true, logger: MyLogger.new)

# crest | 2020-04-02 19:24:58 >> | GET | http://httpbin.org/get
# crest | 2020-04-02 19:24:58 << | 200 | http://httpbin.org/get
