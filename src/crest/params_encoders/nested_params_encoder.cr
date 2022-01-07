module Crest
  class NestedParamsEncoder < Crest::ParamsEncoder
    alias Type = Nil | String | Array(Type) | Hash(String, Type)

    SUBKEYS_REGEX = /[^\[\]]+(?:\]?\[\])?/
    ARRAY_REGEX   = /[\[\]]+\Z/

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

    # Converts the given URI query string into a hash.
    #
    # ```
    # Crest::NestedParamsEncoder.decode("a[]=one&a[]=two&a[]=three&b=true&c=C&d=1")
    # # => {"a" => ["one", "two", "three"], "b" => "true", "c" => "C", "d" => "1"}
    #
    # Crest::NestedParamsEncoder.decode("a=one&a=two&a=three&b=true&c=C&d=1")
    # # => {"a" => ["one", "two", "three"], "b" => "true", "c" => "C", "d" => "1"}
    # ```
    def decode(query : String) : Hash
      params = {} of String => Type

      query.split("&").each do |pair|
        key, value = pair.split("=", 2)
        key = URI.decode(key)
        value = URI.decode(value)

        decode_pair(params, key, value)
      end

      params
    end

    private def decode_pair(context : Hash(String, Type), key : String, value : String)
      subkeys = key.scan(SUBKEYS_REGEX)

      subkeys.each_with_index do |subkey, i|
        is_last_subkey = (i == subkeys.size - 1)
        subkey = subkey[0]

        if match = subkey.match(ARRAY_REGEX)
          subkey = match.pre_match
        end

        context = new_context(context, subkey) unless is_last_subkey

        add_to_context(context, value, subkey) if is_last_subkey
      end
    end

    private def new_context(context, subkey : String)
      context[subkey] ||= {} of String => Type if context.is_a?(Hash)
    end

    private def add_to_context(context, value : String, subkey : String)
      value = value.empty? ? nil : value

      if context.is_a?(Hash)
        if context.has_key?(subkey)
          if context[subkey].is_a?(Array)
            context[subkey].as(Array) << value
          else
            context[subkey] = [context[subkey].as(Type), value.as(Type)]
          end
        else
          context[subkey] = value
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
    def self.flatten_params(object : Hash, parent_key = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, item|
        k, v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

        case v
        when Hash, Array
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
    def self.flatten_params(object : Array, parent_key = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, item|
        processed_key = parent_key ? parent_key : ""

        memo << {processed_key, item}
      end
    end
  end
end
