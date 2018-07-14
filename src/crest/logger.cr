# Copyright (c) 2017 icyleaf
# Licensed under The MIT License (MIT)
# http://opensource.org/licenses/MIT

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
      @filters = [] of Array(String | Regex)
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

    def info(message : String)
      @logger.info(apply_filters(message))
    end

    def filter(patern : String | Regex, replacement : String)
      @filters.push([patern, replacement])
    end

    private def apply_filters(output : String) : String
      @filters.each do |f|
        patern = f[0]
        replacement = f[1]

        output = output.gsub(patern, replacement)
      end

      output
    end
  end
end

require "./loggers/*"
