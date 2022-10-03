require "../../spec_helper"

describe Crest::EnumeratedFlatParamsEncoder do
  describe ".flatten_params" do
    it "transform hash param" do
      input = {"first_name" => "Thomas", "last_name" => "Anders"}
      output = [{"first_name", "Thomas"}, {"last_name", "Anders"}]

      Crest::EnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}, {"key2", "123"}]

      Crest::EnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      output = [{"routes[1][from]", "A"}, {"routes[1][to]", "B"}, {"routes[2][from]", 1}, {"routes[2][to]", 2}]

      Crest::EnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of arrays" do
      input = {"routes" => [["a", "b"], ["c"], [] of String]}
      output = [{"routes[1][1]", "a"}, {"routes[1][2]", "b"}, {"routes[2][1]", "c"}]

      Crest::EnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform JSON::Any" do
      input = JSON.parse(%({"access": [{"name": "mapping", "speed": "fast"}, {"name": "any", "speed": "slow"}]}))
      output = [{"access[1][name]", "mapping"}, {"access[1][speed]", "fast"}, {"access[2][name]", "any"}, {"access[2][speed]", "slow"}]

      Crest::EnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end
  end

  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      # "a[1]=one&a[2]=two&a[3]=three"
      output = "a%5B1%5D=one&a%5B2%5D=two&a%5B3%5D=three"

      Crest::EnumeratedFlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes array with hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      # "routes[1][from]=A&routes[1][to]=B&routes[2][from]=1&routes[2][to]=2"
      output = "routes%5B1%5D%5Bfrom%5D=A&routes%5B1%5D%5Bto%5D=B&routes%5B2%5D%5Bfrom%5D=1&routes%5B2%5D%5Bto%5D=2"

      Crest::EnumeratedFlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes JSON::Any values" do
      input = JSON.parse(File.read(File.join(__DIR__, "../../fixtures/json/complex_object.json")))
      # "name=David&nationality=Danish&address[street]=12+High+Street&address[city]=London&avatar=&location[1]=10&location[2]=20&array[1][a][b][1][c][1]=1.23&array[1][a][b][1][c][2]=2.34&array[1][a][b][1][d]=true&array[1][a][b][1][e]=abc&array[1][a][b][1][f]=12&array[2][a][b][1][c][1]=3.45&array[2][a][b][1][c][2]=5.67&array[2][a][b][1][d]=false&array[2][a][b][1][e]=def&array[2][a][b][1][f]=34"
      output = "name=David&nationality=Danish&address%5Bstreet%5D=12+High+Street&address%5Bcity%5D=London&avatar=&location%5B1%5D=10&location%5B2%5D=20&array%5B1%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bc%5D%5B1%5D=1.23&array%5B1%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bc%5D%5B2%5D=2.34&array%5B1%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bd%5D=true&array%5B1%5D%5Ba%5D%5Bb%5D%5B1%5D%5Be%5D=abc&array%5B1%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bf%5D=12&array%5B2%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bc%5D%5B1%5D=3.45&array%5B2%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bc%5D%5B2%5D=5.67&array%5B2%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bd%5D=false&array%5B2%5D%5Ba%5D%5Bb%5D%5B1%5D%5Be%5D=def&array%5B2%5D%5Ba%5D%5Bb%5D%5B1%5D%5Bf%5D=34"

      Crest::EnumeratedFlatParamsEncoder.encode(input.as_h).should eq(output)
    end
  end
end
