require "../../spec_helper"

describe Crest::NestedParamsEncoder do
  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      output = "a=one&a=two&a=three"

      Crest::NestedParamsEncoder.encode(input).should eq(output)
    end

    it "encodes JSON::Any values" do
      input = JSON.parse(File.read(File.join(__DIR__, "../../fixtures/json/complex_object.json")))
      # "name=David&nationality=Danish&address[street]=12+High+Street&address[city]=London&avatar=&location=10&location=20&array[a][b][c]=1.23&array[a][b][c]=2.34&array[a][b][d]=true&array[a][b][e]=abc&array[a][b][f]=12&array[a][b][c]=3.45&array[a][b][c]=5.67&array[a][b][d]=false&array[a][b][e]=def&array[a][b][f]=34"
      output = "name=David&nationality=Danish&address%5Bstreet%5D=12+High+Street&address%5Bcity%5D=London&avatar=&location=10&location=20&array%5Ba%5D%5Bb%5D%5Bc%5D=1.23&array%5Ba%5D%5Bb%5D%5Bc%5D=2.34&array%5Ba%5D%5Bb%5D%5Bd%5D=true&array%5Ba%5D%5Bb%5D%5Be%5D=abc&array%5Ba%5D%5Bb%5D%5Bf%5D=12&array%5Ba%5D%5Bb%5D%5Bc%5D=3.45&array%5Ba%5D%5Bb%5D%5Bc%5D=5.67&array%5Ba%5D%5Bb%5D%5Bd%5D=false&array%5Ba%5D%5Bb%5D%5Be%5D=def&array%5Ba%5D%5Bb%5D%5Bf%5D=34"

      Crest::NestedParamsEncoder.encode(input.as_h).should eq(output)
    end
  end

  describe "#flatten_params" do
    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr]", "1"}, {"key1[arr]", "2"}, {"key1[arr]", "3"}, {"key2", "123"}]

      Crest::NestedParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of arrays" do
      input = {"routes" => [["a", "b"], ["c"], [] of String]}
      output = [{"routes", "a"}, {"routes", "b"}, {"routes", "c"}]

      Crest::NestedParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform JSON::Any" do
      input = JSON.parse(%({"access": [{"name": "mapping", "speed": "fast"}, {"name": "any", "speed": "slow"}]}))
      output = [{"access[name]", "mapping"}, {"access[speed]", "fast"}, {"access[name]", "any"}, {"access[speed]", "slow"}]

      Crest::NestedParamsEncoder.flatten_params(input).should eq(output)
    end
  end
end
