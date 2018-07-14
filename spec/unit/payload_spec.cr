require "../spec_helper"

describe Crest::Payload do
  describe "#generate" do
    it "generate payload" do
      input = {:file => {"one" => "one", "two" => "two"}}
      parsed_input = [{"file[one]", "one"}, {"file[two]", "two"}]
      content_type = "multipart/form-data"

      payload = Crest::Payload.generate(input)

      payload.content_type.should contain(content_type)
      payload.params.should eq(input)
      payload.parsed_params.should eq(parsed_input)
    end
  end
end
