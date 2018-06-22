# The MIT License (MIT)
#
# Copyright (c) 2017 icyleaf
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "colorize"
require "../logger"

module Crest
  class CommonLogger < Logger
    def request(request)
      message = String.build do |io|
        io << "| " << colorful_method(request.method)
        io << " | " << request.url
        io << " | " << request.payload.to_s.inspect unless request.payload.nil?
      end.to_s

      @logger.info(message)
    end

    def response(response)
      message = String.build do |io|
        io << "| " << colorful_status_code(response.status_code)
        io << " | " << response.url
        io << " | " << response.body.inspect
      end.to_s

      @logger.info(message)
    end

    private def colorful_method(method)
      fore, back = case method
                   when "GET"
                     [:white, :blue]
                   when "POST"
                     [:white, :cyan]
                   when "PUT"
                     [:white, :yellow]
                   when "DELETE"
                     [:white, :red]
                   when "PATCH"
                     [:white, :green]
                   when "HEAD"
                     [:white, :magenta]
                   else
                     [:dark_gray, :white]
                   end
      colorful((" %-7s" % method), fore, back)
    end

    private def colorful_status_code(status_code)
      fore, back = case status_code
                   when 300..399
                     [:dark_gray, :white]
                   when 400..499
                     [:white, :yellow]
                   when 500..599
                     [:white, :red]
                   else
                     [:white, :green]
                   end
      colorful((" %-7s" % status_code), fore, back)
    end

    private def colorful(message, fore, back)
      Colorize.enabled = !@io.is_a?(File)
      message.colorize.fore(fore).back(back)
    end
  end
end
