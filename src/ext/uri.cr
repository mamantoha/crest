# :nodoc:
# https://github.com/crystal-lang/crystal/issues/13114
class URI
  class BadURIError < Exception
  end

  def self.join(*args)
    url = args[1..-1].reduce(URI.parse(args[0])) { |a, e| a.resolve(e) }

    raise BadURIError.new("both URI are relative") if url.relative?

    url
  end
end
