require "../../spec_helper"

describe Crest::NestedParamsEncoder do
  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      output = "a=one&a=two&a=three"

      Crest::NestedParamsEncoder.encode(input).should eq(output)
    end
  end

  describe "#decode" do
    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr]", "1"}, {"key1[arr]", "2"}, {"key1[arr]", "3"}, {"key2", "123"}]

      Crest::NestedParamsEncoder.flatten_params(input).should eq(output)
    end
  end
end
