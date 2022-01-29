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
  end
end
