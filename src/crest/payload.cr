module Crest
  module Payload
    def self.generate(params : Hash)
      content_type = Channel(String).new(1)
      io = IO::Memory.new
      parsed_params = parse_params(params)

      HTTP::FormData.build(io) do |formdata|
        content_type.send(formdata.content_type)

        # Creates an `HTTP::FormData` instance from the key-value
        # pairs of the given `params`.
        parsed_params.each do |name, value|
          add_field(formdata, name.to_s, value)
        end
      end

      return io.to_s, content_type.receive
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : TextValue)
      formdata.field(name.to_s, value.to_s)
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : File)
      metadata = HTTP::FormData::FileMetadata.new(filename: value.path)
      formdata.file(name.to_s, value, metadata)
    end

    def self.parse_params(params : Hash)
      Crest::Utils.flatten_params(params)
    end
  end
end
