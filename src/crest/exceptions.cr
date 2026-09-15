require "./response"

module Crest
  # Hash of HTTP status code => standard-library description.
  STATUSES = ({} of Int32 => String).tap do |statuses|
    HTTP::Status.each do |status|
      if description = status.description
        statuses[status.code] = description
      end
    end
  end

  # This is the base `Crest` exception class. Rescue it if you want to
  # catch any exception that your request might raise
  # You can see anything about the response via `e.response`.
  # For example, the entire result body (which is
  # probably an HTML error page) is `e.response.body`.
  #
  # Hash of HTTP status `code => message`.
  #
  # - `1xx`: Informational - Request received, continuing process
  # - `2xx`: Success - The action was successfully received, understood, and
  #    accepted
  # - `3xx`: Redirection - Further action must be taken in order to complete the
  #    request
  # - `4xx`: Client Error - The request contains bad syntax or cannot be fulfilled
  # - `5xx`: Server Error - The server failed to fulfill an apparently valid
  #    request
  #
  # See [HTTP Status Code Registry](http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml)
  # for more Information.
  class RequestFailed < Exception
    getter response

    def self.subclass_by_status_code(status_code)
      EXCEPTIONS_MAP.fetch(status_code, self)
    end

    def initialize(@response : Crest::Response)
    end

    def http_code
      @response.status_code.to_i
    end

    def message
      result = "HTTP status code #{http_code}"
      if msg = STATUSES[http_code]?
        result += ": #{msg}"
      end
      result
    end
  end

  EXCEPTIONS_MAP = {} of Int32 => Crest::RequestFailed.class

  {% for status in HTTP::Status.constants %}
    {% name = status.stringify.downcase.camelcase %}
    # :nodoc:
    class {{ name.id }} < RequestFailed
    end

    EXCEPTIONS_MAP[HTTP::Status::{{ status.id }}.code] = Crest::{{ name.id }}
  {% end %}
end
