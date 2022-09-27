module Crest
  abstract class Form(T)
    @form_data : String = ""
    @content_type : String = ""

    getter params, form_data, content_type

    def self.generate(params : Hash, params_encoder : Crest::ParamsEncoder.class)
      new(params, params_encoder).generate
    end

    private def initialize(@params : T, @params_encoder : Crest::ParamsEncoder.class)
    end

    abstract def generate
  end
end
