require "../../spec_helper"

describe Crest::FlatParamsEncoder do
  describe "#encode" do
    it "encodes hash" do
      input = {:foo => "123", :bar => "456"}
      output = "foo=123&bar=456"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes hash as http url-encoded" do
      input = {:email => "user@example.com", :title => "Hello world!"}
      output = "email=user%40example.com&title=Hello+world%21"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes hash with nil" do
      input = {:foo => nil, :bar => "2"}
      output = "foo=&bar=2"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes hash with boolean" do
      input = {:foo => true, :bar => "2"}
      output = "foo=true&bar=2"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes hash with symbol" do
      input = {:foo => :bar}
      output = "foo=bar"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes hash with numeric values" do
      input = {:foo => 1, :bar => 2}
      output = "foo=1&bar=2"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"], "b" => true, "c" => "C", "d" => 1}
      output = "a%5B%5D=one&a%5B%5D=two&a%5B%5D=three&b=true&c=C&d=1"

      Crest::FlatParamsEncoder.encode(input).should eq(output)
    end

    it "transform nested param with array of arrays" do
      input = {"routes" => [["a", "b"], ["c"], [] of String]}
      output = [{"routes[][]", "a"}, {"routes[][]", "b"}, {"routes[][]", "c"}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "encodes JSON::Any values" do
      input = JSON.parse(File.read(File.join(__DIR__, "../../fixtures/json/complex_object.json")))
      # "name=David&nationality=Danish&address[street]=12+High+Street&address[city]=London&avatar=&location[]=10&location[]=20&array[][a][b][][c][]=1.23&array[][a][b][][c][]=2.34&array[][a][b][][d]=true&array[][a][b][][e]=abc&array[][a][b][][f]=12&array[][a][b][][c][]=3.45&array[][a][b][][c][]=5.67&array[][a][b][][d]=false&array[][a][b][][e]=def&array[][a][b][][f]=34"
      output = "name=David&nationality=Danish&address%5Bstreet%5D=12+High+Street&address%5Bcity%5D=London&avatar=&location%5B%5D=10&location%5B%5D=20&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bc%5D%5B%5D=1.23&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bc%5D%5B%5D=2.34&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bd%5D=true&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Be%5D=abc&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bf%5D=12&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bc%5D%5B%5D=3.45&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bc%5D%5B%5D=5.67&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bd%5D=false&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Be%5D=def&array%5B%5D%5Ba%5D%5Bb%5D%5B%5D%5Bf%5D=34"

      Crest::FlatParamsEncoder.encode(input.as_h).should eq(output)
    end
  end

  describe "#flatten_params" do
    it "transform nested param" do
      input = {:key1 => {:key2 => "123"}}
      output = [{"key1[key2]", "123"}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param" do
      input = {:key1 => {:key2 => {:key3 => "123"}}}
      output = [{"key1[key2][key3]", "123"}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param with file" do
      file = File.open("#{__DIR__}/../../support/fff.png")
      input = {:key1 => {:key2 => {:key3 => file}}}
      output = [{"key1[key2][key3]", file}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][]", "1"}, {"key1[arr][]", "2"}, {"key1[arr][]", "3"}, {"key2", "123"}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested params with files" do
      file = File.open("#{__DIR__}/../../support/fff.png")

      input = {:key1 => {:key2 => file}}
      output = [{"key1[key2]", file}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with text value and file" do
      file = File.open("#{__DIR__}/../../support/fff.png")
      input = {"user" => {"name" => "Tom", "file" => file}}
      output = [{"user[name]", "Tom"}, {"user[file]", file}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform simple params with nil value" do
      input = {:key1 => nil}
      output = [{"key1", nil}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform JSON::Any" do
      input = JSON.parse(%({"access": [{"name": "mapping", "speed": "fast"}, {"name": "any", "speed": "slow"}]}))
      output = [{"access[][name]", "mapping"}, {"access[][speed]", "fast"}, {"access[][name]", "any"}, {"access[][speed]", "slow"}]

      Crest::FlatParamsEncoder.flatten_params(input).should eq(output)
    end
  end
end
