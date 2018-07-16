require "../spec_helper"

describe Crest::Form do
  describe "#generate" do
    it "generate form" do
      input = {:file => {"one" => "one", "two" => "two"}}
      parsed_input = [{"file[one]", "one"}, {"file[two]", "two"}]
      content_type = "multipart/form-data"

      form = Crest::Form.generate(input)

      form.content_type.should contain(content_type)
      form.params.should eq(input)
      form.parsed_params.should eq(parsed_input)
    end
  end
end
