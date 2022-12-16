module Crest
  # Custom serializers
  #
  # You can build your custom encoder, if you like.
  # The value of `params_encoder` can be any `Crest::ParamsEncoder` object that responds to: `#encode(Hash) #=> String`
  #
  # The encoder will affect both how Crest processes query strings and how it serializes POST bodies.
  #
  # The default encoder is `Crest::FlatParamsEncoder`.
  abstract class ParamsEncoder
    abstract def encode(params : Hash) : String

    def self.encode(params : Hash) : String
      new.encode(params)
    end

    # Transform JSON::Any `object` into a flat array of `{key, value}`.
    #
    # # `parent_key` — Should not be passed (used for recursion)
    #
    # ```
    # params = JSON.parse(%({"access": [{"name": "mapping", "speed": "fast"}, {"name": "any", "speed": "slow"}]}))
    #
    # Crest::FlatParamsEncoder.flatten_params(params)
    # # => [{"access[][name]", "mapping"}, {"access[][speed]", "fast"}, {"access[][name]", "any"}, {"access[][speed]", "slow"}]
    #
    # Crest::EnumeratedFlatParamsEncoder.flatten_params(params)
    # # => [{"access[1][name]", "mapping"}, {"access[1][speed]", "fast"}, {"access[2][name]", "any"}, {"access[2][speed]", "slow"}]
    # ```
    def self.flatten_params(object : JSON::Any, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
      if hash = object.as_h?
        flatten_params(hash, parent_key)
      elsif array = object.as_a?
        flatten_params(array, parent_key)
      else
        processed_key = parent_key ? parent_key : ""
        value : Crest::ParamsValue = nil

        value = object.as_i64? if value.nil?
        value = object.as_f? if value.nil?
        value = object.as_bool? if value.nil?
        value = object.as_s? if value.nil?

        [{processed_key, value.as(Crest::ParamsValue)}]
      end
    end
  end
end
