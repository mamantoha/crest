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
  end
end
