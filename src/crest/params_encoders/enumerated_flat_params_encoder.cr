module Crest
  class EnumeratedFlatParamsEncoder < Crest::ParamsEncoder
    # ```
    # Crest::EnumeratedFlatParamsEncoder.encode({"a" => ["one", "two", "three"], "b" => true, "c" => "C", "d" => 1})
    # # => 'a[1]=one&a[2]=two&a[3]=three&b=true&c=C&d=1'
    # ```
    def encode(params : Hash) : String
      HTTP::Params.build do |form|
        self.class.flatten_params(params).each do |name, value|
          form.add(name.to_s, value.to_s)
        end
      end
    end

    # ```
    # Crest::EnumeratedFlatParamsEncoder.flatten_params({:key1 => {:key2 => "123"}})
    # # => [{"key1[key2]", "123"}]
    # ```
    def self.flatten_params(object : Hash, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, item|
        k, v = item

        processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

        case v
        when Hash, Array, JSON::Any
          memo += flatten_params(v, processed_key)
        else
          memo << {processed_key, v}
        end
      end
    end

    # ```
    # Crest::EnumeratedFlatParamsEncoder.flatten_params({:key1 => {:arr => ["1", "2", "3"]}})
    # # => [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}]
    # ```
    def self.flatten_params(object : Array, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      object.each_with_index(0).reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, (item, index)|
        processed_key = parent_key ? "#{parent_key}[#{index}]" : ""

        case item
        when Hash, JSON::Any
          memo += flatten_params(item, processed_key)
        else
          memo << {processed_key, item}
        end
      end
    end

    def self.flatten_params(object : JSON::Any, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      if hash = object.as_h?
        flatten_params(hash, parent_key)
      elsif array = object.as_a?
        flatten_params(array, parent_key)
      else
        value : Crest::ParamsValue = nil
        value = object.as_f? if value.nil?
        value = object.as_i64? if value.nil?
        value = object.as_bool? if value.nil?
        value = object.as_s? if value.nil?
        [{parent_key, value.as(Crest::ParamsValue)}]
      end
    end
  end
end
