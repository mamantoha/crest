require "../../spec_helper"

describe Crest::EnumeratedNestedParamsEncoder do
  describe ".flatten_params" do
    it "transform hash param" do
      input = {"first_name" => "Thomas", "last_name" => "Anders"}
      output = [{"first_name", "Thomas"}, {"last_name", "Anders"}]

      Crest::EnumeratedNestedParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}, {"key2", "123"}]

      Crest::EnumeratedNestedParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      output = [{"routes[1][from]", "A"}, {"routes[1][to]", "B"}, {"routes[2][from]", 1}, {"routes[2][to]", 2}]

      Crest::EnumeratedNestedParamsEncoder.flatten_params(input).should eq(output)
    end
  end

  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      # "a[1]=one&a[2]=two&a[3]=three"
      output = "a%5B1%5D=one&a%5B2%5D=two&a%5B3%5D=three"

      Crest::EnumeratedNestedParamsEncoder.encode(input).should eq(output)
    end

    it "encodes array with hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      # "routes[1][from]=A&routes[1][to]=B&routes[2][from]=1&routes[2][to]=2"
      output = "routes%5B1%5D%5Bfrom%5D=A&routes%5B1%5D%5Bto%5D=B&routes%5B2%5D%5Bfrom%5D=1&routes%5B2%5D%5Bto%5D=2"

      Crest::EnumeratedNestedParamsEncoder.encode(input).should eq(output)
    end
  end
end
