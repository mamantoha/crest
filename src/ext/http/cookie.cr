# :nodoc:
# https://github.com/crystal-lang/crystal/issues/10983
module HTTP
  class Cookie
    private def validate_name(name)
      raise IO::Error.new("Invalid cookie name") if name.empty?
      name.each_byte do |byte|
        # valid characters for cookie-name per https://tools.ietf.org/html/rfc6265#section-4.1.1
        # and https://tools.ietf.org/html/rfc2616#section-2.2
        # "!#$%&'*+-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ^_`abcdefghijklmnopqrstuvwxyz|~"
        if !byte.in?(0x21...0x7f) ||                 # Non-printable ASCII character
           byte.in?(0x22, 0x28, 0x29, 0x2c, 0x2f) || # '"', '(', ')', ',', '/'
           byte.in?(0x3a..0x40) ||                   # ':', ';', '<', '=', '>', '?', '@'
           byte.in?(0x5c, 0x7b, 0x7d)                # '\\', '{', '}'
          raise IO::Error.new("Invalid cookie name")
        end
      end
    end
  end
end
