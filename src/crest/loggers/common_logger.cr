module Crest
  class CommonLogger < Logger
    def request(request)
      message = String.build do |io|
        io << "| " << request.method
        io << " | " << request.url
        io << " | " << request.payload unless request.payload.nil?
      end.to_s

      @logger.info(message)
    end

    def response(response)
      message = String.build do |io|
        io << "| " << response.status_code
        io << " | " << response.url
        io << " | " << response.body
      end.to_s

      @logger.info(message)
    end
  end
end
