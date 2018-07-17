require "../spec_helper"

describe Crest::Utils do
  describe "#flatten_params" do
    it "transform nested param" do
      input = {:key1 => {:key2 => "123"}}
      output = [{"key1[key2]", "123"}]

      Crest::Utils.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param" do
      input = {:key1 => {:key2 => {:key3 => "123"}}}
      output = [{"key1[key2][key3]", "123"}]

      Crest::Utils.flatten_params(input).should eq(output)
    end

    it "transform deeply nested param with file" do
      file = File.open("#{__DIR__}/../support/fff.png")
      input = {:key1 => {:key2 => {:key3 => file}}}
      output = [{"key1[key2][key3]", file}]

      Crest::Utils.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][]", "1"}, {"key1[arr][]", "2"}, {"key1[arr][]", "3"}, {"key2", "123"}]

      Crest::Utils.flatten_params(input).should eq(output)
    end

    it "parse nested params with files" do
      file = File.open("#{__DIR__}/../support/fff.png")

      input = {:key1 => {:key2 => file}}
      output = [{"key1[key2]", file}]

      Crest::Utils.flatten_params(input).should eq(output)
    end

    it "parse simple params with nil value" do
      input = {:key1 => nil}
      output = [{"key1", nil}]

      Crest::Utils.flatten_params(input).should eq(output)
    end
  end

  describe "#encode_query_string" do
    it "serialize hash" do
      input = {:foo => "123", :bar => "456"}
      output = "foo=123&bar=456"

      Crest::Utils.encode_query_string(input).should eq(output)
    end

    it "serialize hash as http url-encoded" do
      input = {:email => "user@example.com", :title => "Hello world!"}
      output = "email=user%40example.com&title=Hello+world%21"

      Crest::Utils.encode_query_string(input).should eq(output)
    end

    it "serialize hash with nil" do
      input = {:foo => nil, :bar => "456"}
      output = "foo=&bar=456"

      Crest::Utils.encode_query_string(input).should eq(output)
    end

    it "serialize hash with symbol" do
      input = {:foo => :bar}
      output = "foo=bar"

      Crest::Utils.encode_query_string(input).should eq(output)
    end

    it "serialize hash with numeric values" do
      input = {:foo => 123, :bar => 456}
      output = "foo=123&bar=456"

      Crest::Utils.encode_query_string(input).should eq(output)
    end
  end
end
