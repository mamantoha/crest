module Crest
  # Various utility methods
  module Utils
    extend self

    # Serialize hash object into HTTP query string parameters
    #
    # ```crystal
    # encode_query_string({:foo => "123", :bar => 456})
    # # => "foo=123&bar=456"
    # ```
    def encode_query_string(object : Hash)
      HTTP::Params.build do |form|
        flatten_params(object).each do |name, value|
          form.add(name.to_s, value.to_s)
        end
      end
    end

    # Transform deeply nested param containers into a flat hash of `key => value`.
    #
    # ```crystal
    # Crest::Utils.flatten_params({:key1 => {:key2 => "123"}})
    # # => [{"key1[key2]", "123"}]
    # ```
    def flatten_params(object : Hash, parent_key = nil)
      object.reduce([] of Tuple(String, TextValue | File)) do |memo, item|
        k, v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

        case v
        when Hash, Array
          memo += flatten_params(v, processed_key)
        else
          memo << {processed_key, v}
        end

        memo
      end
    end

    # Transform deeply nested param containers into a flat hash of `key => value`.
    #
    # ```crystal
    # Crest::Utils.flatten_params({:key1 => {:arr => ["1", "2", "3"]}})
    # # => [{"key1[arr][]", "1"}, {"key1[arr][]", "2"}, {"key1[arr][]", "3"}]
    # ```
    def flatten_params(object : Array, parent_key = nil)
      object.reduce([] of Tuple(String, TextValue | File)) do |memo, item|
        k = :""
        v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s
        memo << {processed_key, v}

        memo
      end
    end
  end
end
