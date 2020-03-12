require "../spec_helper"

describe Crest::ParamsEncoder do
  describe "#encode" do
    it do
      params = {"foo" => "1", "bar" => "2"}
      query = "foo=1&bar=2"
      Crest::ParamsEncoder.encode(params).should eq(query)
    end

    it do
      params = {"foo" => "bar", "baz" => ["quux", "quuz"]}

      # "foo=bar&baz[]=quux&baz[]=quuz"
      query = "foo=bar&baz%5B%5D=quux&baz%5B%5D=quuz"

      Crest::ParamsEncoder.encode(params).should eq(query)
    end

    it do
      params = {"user" => {"login" => "admin"}}

      # "user[login]=admin"
      query = "user%5Blogin%5D=admin"

      Crest::ParamsEncoder.encode(params).should eq(query)
    end

    it do
      params = {"key1" => {"arr" => ["1", "2", "3"]}, "key2" => "123"}

      # "key1[arr][]=1&key1[arr][]=2&key1[arr][]=3&key2=123"
      query = "key1%5Barr%5D%5B%5D=1&key1%5Barr%5D%5B%5D=2&key1%5Barr%5D%5B%5D=3&key2=123"

      Crest::ParamsEncoder.encode(params).should eq(query)
    end
  end

  describe "#decode" do
    it do
      query = "foo=1&bar=2"
      params = {"foo" => "1", "bar" => "2"}

      Crest::ParamsEncoder.decode(query).should eq(params)
    end

    it do
      query = "foo=bar&baz%5B%5D=quux&baz%5B%5D=quuz"
      params = {"foo" => "bar", "baz" => ["quux", "quuz"]}

      Crest::ParamsEncoder.decode(query).should eq(params)
    end

    it do
      query = "user%5Blogin%5D=admin"
      params = {"user" => {"login" => "admin"}}

      Crest::ParamsEncoder.decode(query).should eq(params)
    end
  end
end
