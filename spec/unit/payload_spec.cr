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
      output = {"key1" => "123"}

      Crest::Payload.parse_params(input).should eq(output)
    end

    it "parse simple params with numeric values" do
      input = {:key1 => 123}
      output = {"key1" => 123}

      Crest::Payload.parse_params(input).should eq(output)
    end

    it "parse simple params with nil value" do
      input = {:key1 => nil}
      output = {"key1" => nil}

      Crest::Payload.parse_params(input).should eq(output)
    end

    it "parse nested params" do
      input = {:key1 => {:key2 => "123"}}
      output = {"key1[key2]" => "123"}

      Crest::Payload.parse_params(input).should eq(output)
    end

    it "parse nested params with files" do
      file = File.open("#{__DIR__}/../support/fff.png")

      input = {:key1 => {:key2 => file}}
      output = {"key1[key2]" => file}

      Crest::Payload.parse_params(input).should eq(output)
    end
  end
end
