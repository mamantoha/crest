require "../form"

module Crest
  # This class lets `crest` convert request hash to JSON
  # This causes `crest` to POST data using the
  # "Content-Type" `application/json`.
  class JSONForm(T) < Crest::Form(T)
    @content_type : String = "application/json"

    def generate
      @form_data = JSON.build do |json|
        serialize(@params, json)
      end

      self
    end

    private def serialize(value, json : JSON::Builder) : Nil
      case value
      when Hash
        json.object do
          value.each do |key, item|
            json.field key.to_json_object_key do
              serialize(item, json)
            end
          end
        end
      when Array
        json.array do
          value.each do |item|
            serialize(item, json)
          end
        end
      when IO
        raise ArgumentError.new("IO values cannot be encoded as JSON; use multipart or a raw request body")
      else
        value.to_json(json)
      end
    end
  end
end
