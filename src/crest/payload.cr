module Crest
  module Payload
    def self.generate(params : Hash)
      content_type = Channel(String).new(1)
      io = IO::Memory.new

      HTTP::FormData.build(io) do |formdata|
        content_type.send(formdata.content_type)

        params.each do |name, value|
          add_field(formdata, name, value)
        end
      end

      return io.to_s, content_type.receive
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : String)
      formdata.field(name.to_s, value)
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : File)
      metadata = HTTP::FormData::FileMetadata.new(filename: value.path)
      formdata.file(name.to_s, value, metadata)
    end

  end
end
