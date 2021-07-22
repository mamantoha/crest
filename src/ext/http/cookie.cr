# https://github.com/crystal-lang/crystal/issues/10983
module HTTP
  class Cookie
    private def validate_name(name)
      raise IO::Error.new("Invalid cookie name") if name.empty?
      name.each_byte do |byte|
        # valid characters for cookie-name per https://tools.ietf.org/html/rfc6265#section-4.1.1
        # and https://tools.ietf.org/html/rfc2616#section-2.2
        # "!#$%&'*+-.0123456789ABCDEFGHIJKLMNOPQRSTUWVXYZ^_`abcdefghijklmnopqrstuvwxyz|~"
        #
        # + Allows "[" and "]" in the cookies name
        unless (0x21...0x7f).includes?(byte) && byte != 0x22 && byte != 0x28 && byte != 0x29 && byte != 0x2c && byte != 0x2f && !(0x3a..0x40).includes?(byte) && byte != 0x5c && byte != 0x7b && byte != 0x7d
          raise IO::Error.new("Invalid cookie name")
        end
      end
    end
  end
end
