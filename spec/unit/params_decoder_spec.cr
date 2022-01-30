require "../spec_helper"

describe Crest::ParamsDecoder do
  it "decodes simple params" do
    query = "foo=1&bar=2"
    params = {"foo" => "1", "bar" => "2"}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes params with nil" do
    query = "foo=&bar=2"
    params = {"foo" => nil, "bar" => "2"}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes array" do
    query = "a[]=one&a[]=two&a[]=three"
    params = {"a" => ["one", "two", "three"]}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes array without []" do
    query = "a=1&a=2&a=3"
    params = {"a" => ["1", "2", "3"]}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes array with numeric keys" do
    query = "a[1]=one&a[2]=two&a[3]=three"
    params = {"a" => ["one", "two", "three"]}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes hashes" do
    query = "a[b1]=one&a[b2]=two&a[b][c]=foo"
    params = {"a" => {"b1" => "one", "b2" => "two", "b" => {"c" => "foo"}}}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes hashes with nested array" do
    query = "user[a]=1&user[a]=2&user[a]=3"
    params = {"user" => {"a" => ["1", "2", "3"]}}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes escaped string" do
    query = "user%5Blogin%5D=admin"
    params = {"user" => {"login" => "admin"}}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes params with nil" do
    query = "foo=&bar=2"
    params = {"foo" => nil, "bar" => "2"}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes array with hashes" do
    query = "routes[][from]=A&routes[][to]=B&routes[][from]=X&routes[][to]=Y"
    params = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => "X", "to" => "Y"}]}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes array wuth numeric keys and hashes" do
    query = "routes[1][from]=A&routes[1][to]=B&routes[2][from]=X&routes[2][to]=Y"
    params = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => "X", "to" => "Y"}]}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes nested ignores malformed keys" do
    query = "=1&[]=2"
    params = {} of String => Crest::ParamsDecoder::Type

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes nested subkeys dont have to be in brackets" do
    query = "a[b]c[d]e=1"
    params = {"a" => {"b" => {"c" => {"d" => {"e" => "1"}}}}}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end

  it "decodes nested final value overrides any type" do
    query = "a[b][c]=1&a[b]=2"
    params = {"a" => {"b" => [{"c" => "1"}, "2"]}}

    Crest::ParamsDecoder.decode(query).should eq(params)
  end
end
