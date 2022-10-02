require "../../spec_helper"

describe Crest::ZeroEnumeratedFlatParamsEncoder do
  describe ".flatten_params" do
    it "transform hash param" do
      input = {"first_name" => "Thomas", "last_name" => "Anders"}
      output = [{"first_name", "Thomas"}, {"last_name", "Anders"}]

      Crest::ZeroEnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][0]", "1"}, {"key1[arr][1]", "2"}, {"key1[arr][2]", "3"}, {"key2", "123"}]

      Crest::ZeroEnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      output = [{"routes[0][from]", "A"}, {"routes[0][to]", "B"}, {"routes[1][from]", 1}, {"routes[1][to]", 2}]

      Crest::ZeroEnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of arrays" do
      input = {"routes" => [["a", "b"], ["c"], [] of String]}
      output = [{"routes[0][0]", "a"}, {"routes[0][1]", "b"}, {"routes[1][0]", "c"}]

      Crest::ZeroEnumeratedFlatParamsEncoder.flatten_params(input).should eq(output)
    end
  end

  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      # "a[0]=one&a[1]=two&a[2]=three"
      output = "a%5B0%5D=one&a%5B1%5D=two&a%5B2%5D=three"

      Crest::ZeroEnumeratedFlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes array with hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      # "routes[0][from]=A&routes[0][to]=B&routes[1][from]=1&routes[1][to]=2"
      output = "routes%5B0%5D%5Bfrom%5D=A&routes%5B0%5D%5Bto%5D=B&routes%5B1%5D%5Bfrom%5D=1&routes%5B1%5D%5Bto%5D=2"

      Crest::ZeroEnumeratedFlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes JSON::Any values" do
      input = JSON.parse(File.read(File.join(__DIR__, "../../fixtures/json/complex_object.json")))
      # "name=David&nationality=Danish&address[street]=12+High+Street&address[city]=London&avatar=&location[0]=10&location[1]=20&array[0][a][b][0][c][0]=1.23&array[0][a][b][0][c][1]=2.34&array[0][a][b][0][d]=true&array[0][a][b][0][e]=abc&array[0][a][b][0][f]=12&array[1][a][b][0][c][0]=3.45&array[1][a][b][0][c][1]=5.67&array[1][a][b][0][d]=false&array[1][a][b][0][e]=def&array[1][a][b][0][f]=34"
      output = "name=David&nationality=Danish&address%5Bstreet%5D=12+High+Street&address%5Bcity%5D=London&avatar=&location%5B0%5D=10&location%5B1%5D=20&array%5B0%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bc%5D%5B0%5D=1.23&array%5B0%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bc%5D%5B1%5D=2.34&array%5B0%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bd%5D=true&array%5B0%5D%5Ba%5D%5Bb%5D%5B0%5D%5Be%5D=abc&array%5B0%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bf%5D=12&array%5B1%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bc%5D%5B0%5D=3.45&array%5B1%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bc%5D%5B1%5D=5.67&array%5B1%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bd%5D=false&array%5B1%5D%5Ba%5D%5Bb%5D%5B0%5D%5Be%5D=def&array%5B1%5D%5Ba%5D%5Bb%5D%5B0%5D%5Bf%5D=34"

      Crest::ZeroEnumeratedFlatParamsEncoder.encode(input.as_h).should eq(output)
    end
  end
end
