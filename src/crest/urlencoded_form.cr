module Crest
  # This class lets `crest` emulate a filled-in form
  # in which a user has pressed the submit button.
  # This causes `crest` to POST data using the
  # "Content-Type" `application/x-www-form-urlencoded`.
  class UrlencodedForm(T)
    @form_data : String = ""
    @content_type : String = "application/x-www-form-urlencoded"

    getter params, form_data, content_type

    def self.generate(params : Hash)
      new(params).generate
    end

    def initialize(@params : T)
    end

    def generate
      @form_data = parsed_params

      self
    end

    def parsed_params
      Crest::Utils.encode_query_string(@params)
    end
  end
end
