module Crest
  module Payload
    def self.generate(params : Hash)
      content_type = Channel(String).new(1)
      io = IO::Memory.new
      parsed_params = parse_params(params)

      HTTP::FormData.build(io) do |formdata|
        content_type.send(formdata.content_type)

        # Creates an `HTTP::FormData` instance from the key-value
        # pairs of the given *params*.
        #
        parsed_params.each do |name, value|
          add_field(formdata, name.to_s, value)
        end
      end

      return io.to_s, content_type.receive
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : String | Symbol)
      formdata.field(name.to_s, value.to_s)
    end

    def self.add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : File)
      metadata = HTTP::FormData::FileMetadata.new(filename: value.path)
      formdata.file(name.to_s, value, metadata)
    end

    # Transform deeply nested param containers into a flat hash of `key => value`.
    #
    # >> flatten_params({:key1 => {:key2 => "123"}})
    # => {"key1[key2]" => "123"}
    #
    def self.flatten_params(object : Hash, parent_key = nil)
      object.reduce({} of String => (String | File)) do |memo, item|
        k, v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

        case v
        when Hash, Array
          memo.merge!(flatten_params(v, processed_key))
        else
          memo[processed_key] = v
        end

        memo
      end
    end

    # >> flatten_params({:key1 => {:arr => ["1", "2", "3"]}})
    # => {"key1[arr][]" => "1", "key1[arr][]" => "2", "key1[arr][]" => "3"}
    #
    def self.flatten_params(object : Array, parent_key = nil)
      object.reduce({} of String => (String | File)) do |memo, item|
        k = :""
        v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s
        memo[processed_key] = v

        memo
      end
    end

    def self.parse_params(params : Hash)
      flatten_params(params).to_h
    end

  end
end
