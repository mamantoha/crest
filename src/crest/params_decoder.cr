module Crest
  # Module for decoding query-string into parameters.
  module ParamsDecoder
    extend self

    alias Type = Nil | String | Array(Type) | Hash(String, Type)

    SUBKEYS_REGEX = /[^\[\]]+(?:\]?\[\])?/
    ARRAY_REGEX   = /[\[\]]+\Z/

    # Converts the given URI query string into a hash.
    #
    # ```
    # Crest::ParamsDecoder.decode("a[]=one&a[]=two&a[]=three&b=true&c=C&d=1")
    # # => {"a" => ["one", "two", "three"], "b" => "true", "c" => "C", "d" => "1"}
    #
    # Crest::ParamsDecoder.decode("a=one&a=two&a=three&b=true&c=C&d=1")
    # # => {"a" => ["one", "two", "three"], "b" => "true", "c" => "C", "d" => "1"}
    # ```
    def decode(query : String) : Hash(String, Type)
      params = {} of String => Type

      query.split('&').each do |pair|
        next if pair.empty?

        key, value = pair.split('=', 2)
        key = URI.decode(key)
        value = URI.decode(value)
        decode_pair(key, value, params)
      end

      dehash(params).as(Hash)
    end

    private def decode_pair(key : String, value : String, context : Hash(String, Type)) : Nil
      subkeys = key.scan(SUBKEYS_REGEX)

      subkeys.each_with_index do |subkey, i|
        is_array = false

        last_subkey = (i == subkeys.size - 1)
        subkey = subkey[0]

        if match = subkey.match(ARRAY_REGEX)
          is_array = true
          subkey = match.pre_match
        end

        context = prepare_context(context, subkey, is_array, last_subkey)
        add_to_context(is_array, context, value, subkey) if last_subkey
      end
    end

    private def prepare_context(context, subkey : String, is_array : Bool, last_subkey : Bool) : Hash(String, Type) | Array(Type) | String | Nil
      if !last_subkey || is_array
        context = new_context(subkey, is_array, context) if context.is_a?(Hash)
      end

      if context.is_a?(Array) && !is_array
        context = match_context(context, subkey)
      end

      context
    end

    private def new_context(subkey, is_array : Bool, context) : Hash(String, Type) | Array(Type) | String
      value_type = is_array ? Array(Type) : Hash(String, Type)

      context[subkey] ||= value_type.new
    end

    def match_context(context, subkey) : Type | Nil
      context << {} of String => Type if !context.last?.is_a?(Hash) || context.last.as(Hash).has_key?(subkey)
      context.last?
    end

    private def add_to_context(is_array : Bool, context, value : String, subkey : String) : Nil
      value = value.empty? ? nil : value

      if is_array
        context.as(Array) << value
      else
        if context.is_a?(Hash)
          if context.has_key?(subkey)
            if context[subkey].is_a?(Array)
              context[subkey].as(Array) << value.as(Type)
            else
              context[subkey] = [context[subkey].as(Type), value.as(Type)]
            end
          else
            context[subkey] = value
          end
        end
      end

      nil
    end

    # Converts a nested hash with purely numeric keys into an array.
    private def dehash(hash, depth = 0) : Hash(String, Type) | Array(Type)
      hash.each do |key, value|
        hash[key] = dehash(value, depth + 1) if value.is_a?(Hash)
      end

      if depth.positive? && !hash.empty? && hash.keys.all? { |k| k =~ /^\d+$/ }
        hash.map(&.last)
      else
        hash
      end
    end
  end
end
