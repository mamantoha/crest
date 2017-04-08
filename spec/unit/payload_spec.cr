require "../spec_helper"

describe Crest::Payload do

  describe "#generate" do
    it "generate payload" do
      input = {"files[one]" => "one", "files[two]" => "two"}
      output = "multipart/form-data"

      Crest::Payload.generate(input).to_s.should contain(output)
    end
  end

  describe "#flatten_params" do
    it "transform nested param" do
      input = {:key1 => {:key2 => "123"}}
      output = [["key1[key2]", "123"]]

      Crest::Payload.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param" do
      input = {:key1 => {:key2 => {:key3 => "123"}}}
      output = [["key1[key2][key3]", "123"]]

      Crest::Payload.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param with file" do
      file = File.open("#{__DIR__}/../support/fff.png")
      input = {:key1 => {:key2 => {:key3 => file}}}
      output = [["key1[key2][key3]", file]]

      Crest::Payload.flatten_params(input).should eq(output)
    end


    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [["key1[arr][]", "1"], ["key1[arr][]", "2"], ["key1[arr][]", "3"], ["key2", "123"]]

      Crest::Payload.flatten_params(input).should eq(output)
    end
  end

  describe "#parse_params" do

    it "parse simple params" do
      input = {:key1 => "123"}
      output = {"key1" => "123"}

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
