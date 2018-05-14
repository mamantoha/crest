require "../spec_helper"

describe Crest::Payload do
  describe "#generate" do
    it "generate payload" do
      input = {"files[one]" => "one", "files[two]" => "two"}
      output = "multipart/form-data"

      Crest::Payload.generate(input).to_s.should contain(output)
    end
  end

  describe "#parse_params" do
    it "parse simple params" do
      input = {:key1 => "123"}
      output = [{"key1", "123"}]

      Crest::Payload.parse_params(input).should eq(output)
    end
  end
end
