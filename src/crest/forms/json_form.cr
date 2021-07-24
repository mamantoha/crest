require "../form"

module Crest
  # This class lets `crest` convert request hash to JSON
  # This causes `crest` to POST data using the
  # "Content-Type" `application/json`.
  class JSONForm(T) < Crest::Form(T)
    @content_type : String = "application/json"

    def generate
      @form_data = @params.to_json

      self
    end
  end
end
