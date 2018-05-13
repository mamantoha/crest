require "logger"

module Crest
  abstract class Logger
    def self.new(filename : String)
      new(File.open(filename, "w"))
    end

    forward_missing_to @logger

    def initialize(@io : IO = STDOUT)
      @logger = ::Logger.new(@io)
      @logger.level = ::Logger::DEBUG
      @logger.progname = "crest"
      @logger.formatter = default_formatter
    end

    abstract def request(request : Crest::Request) : String
    abstract def response(response : Crest::Response) : String

    def default_formatter
      ::Logger::Formatter.new do |_, datetime, progname, message, io|
        io << progname
        io << " | " << datetime.to_s("%F %T")
        io << " " << message
      end
    end
  end
end

require "./loggers/*"
