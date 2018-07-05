module Crest
  class Payload
    @form_data : String = ""
    @content_type : String = ""

    getter form_data, content_type

    def self.generate(params : Hash)
      new.generate(params)
    end

    # :nodoc:
    def initialize
    end

    def generate(params : Hash)
      content_type_ch = Channel(String).new(1)
      io = IO::Memory.new
      parsed_params = parse_params(params)

      HTTP::FormData.build(io) do |formdata|
        content_type_ch.send(formdata.content_type)

        # Creates an `HTTP::FormData` instance from the key-value
        # pairs of the given `params`.
        parsed_params.each do |name, value|
          add_field(formdata, name.to_s, value)
        end
      end

      @form_data = io.to_s
      @content_type = content_type_ch.receive

      self
    end

    private def add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : TextValue)
      formdata.field(name.to_s, value.to_s)
    end

    private def add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : File)
      metadata = HTTP::FormData::FileMetadata.new(filename: value.path)
      formdata.file(name.to_s, value, metadata)
    end

    private def parse_params(params : Hash)
      Crest::Utils.flatten_params(params)
    end
  end
end
