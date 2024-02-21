module Crest
  class NestedParamsEncoder < Crest::ParamsEncoder
    # Converts the given params into a URI query string. Keys and values
    # will converted to strings and appropriately escaped for the URI.
    #
    # ```
    # Crest::NestedParamsEncoder.encode({"a" => ["one", "two", "three"], "b" => true, "c" => "C", "d" => 1})
    # # => 'a=one&a=two&a=three&b=true&c=C&d=1'
    # ```
    def encode(params : Hash) : String
      HTTP::Params.build do |form|
        self.class.flatten_params(params).each do |name, value|
          form.add(name.to_s, value.to_s)
        end
      end
    end

    # Transform deeply nested params containers into a flat array of `{key, value}`.
    #
    # `parent_key` — Should not be passed (used for recursion)
    #
    # ```
    # Crest::NestedParamsEncoder.flatten_params({:key1 => {:key2 => "123"}})
    # # => [{"key1[key2]", "123"}]
    # ```
    def self.flatten_params(object : Hash, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, (k, v)|
        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

        case v
        when Hash, Array, JSON::Any
          memo += flatten_params(v, processed_key)
        else
          memo << {processed_key, v}
        end
      end
    end

    # Transform deeply nested params containers into a flat array of `{key, value}`.
    #
    # `parent_key` — Should not be passed (used for recursion)
    #
    # ```
    # Crest::NestedParamsEncoder.flatten_params({:key1 => {:arr => ["1", "2", "3"]}})
    # # => [{"key1[arr]", "1"}, {"key1[arr]", "2"}, {"key1[arr]", "3"}]
    # ```
    def self.flatten_params(object : Array, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, item|
        processed_key = parent_key ? parent_key : ""

        case item
        when Hash, Array, JSON::Any
          memo += flatten_params(item, processed_key)
        else
          memo << {processed_key, item}
        end
      end
    end
  end
end
