require "../spec_helper"

describe Crest::Payload do
  describe "#generate" do
    it "generate payload" do
      input = {"files[one]" => "one", "files[two]" => "two"}
      content_type = "multipart/form-data"

      payload = Crest::Payload.generate(input)

      payload.content_type.should contain(content_type)
    end
  end
end
