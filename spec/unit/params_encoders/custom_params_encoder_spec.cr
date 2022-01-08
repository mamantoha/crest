require "../../spec_helper"

class CustomParamsEncoder < Crest::ParamsEncoder
  alias Type = Nil | String | Array(Type) | Hash(String, Type)

  SUBKEYS_REGEX = /[^\[\]]+(?:\]?\[\d+\])?/
  ARRAY_REGEX   = /[\[\d+\]]+\Z/

  # ```
  # CustomParamsEncoder.encode({"a" => ["one", "two", "three"], "b" => true, "c" => "C", "d" => 1})
  # # => 'a[1]=one&a[2]=two&a[3]=three&b=true&c=C&d=1'
  # ```
  def encode(params : Hash) : String
    HTTP::Params.build do |form|
      self.class.flatten_params(params).each do |name, value|
        form.add(name.to_s, value.to_s)
      end
    end
  end

  # ```
  # CustomParamsEncoder.decode("a[1]=one&a[2]=two&a[3]=three&b=true&c=C&d=1")
  # # => {"a" => ["one", "two", "three"], "b" => "true", "c" => "C", "d" => "1"}
  # ```
  def decode(query : String) : Hash
    query.split("&").reduce({} of String => Type) do |params, pair|
      key, value = pair.split("=", 2)
      key = URI.decode(key)
      value = URI.decode(value)

      decode_pair!(params, key, value)

      params
    end
  end

  private def decode_pair!(context : Hash(String, Type), key : String, value : String)
    subkeys = key.scan(SUBKEYS_REGEX)

    subkeys.each_with_index do |subkey, i|
      is_last_subkey = (i == subkeys.size - 1)
      subkey = subkey[0]
      p! subkey

      if match = subkey.match(ARRAY_REGEX)
        p! match
        subkey = match.pre_match
        p! subkey
      end

      context = new_context(context, subkey) unless is_last_subkey

      add_to_context(context, value, subkey) if is_last_subkey
    end
  end

  private def new_context(context, subkey : String)
    context[subkey] ||= {} of String => Type if context.is_a?(Hash)
  end

  private def add_to_context(context, value : String, subkey : String)
    value = value.empty? ? nil : value

    if context.is_a?(Hash)
      if context.has_key?(subkey)
        if context[subkey].is_a?(Array)
          context[subkey].as(Array) << value
        else
          context[subkey] = [context[subkey].as(Type), value.as(Type)]
        end
      else
        context[subkey] = value
      end
    end
  end

  # ```
  # CustomParamsEncoder.flatten_params({:key1 => {:key2 => "123"}})
  # # => [{"key1[key2]", "123"}]
  # ```
  def self.flatten_params(object : Hash, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
    object.reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, item|
      k, v = item

      processed_key = parent_key ? "#{parent_key}[#{k}]" : k.to_s

      case v
      when Hash, Array
        memo += flatten_params(v, processed_key)
      else
        memo << {processed_key, v}
      end
    end
  end

  # ```
  # CustomParamsEncoder.flatten_params({:key1 => {:arr => ["1", "2", "3"]}})
  # # => [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}]
  # ```
  def self.flatten_params(object : Array, parent_key : String? = nil) : Array(Tuple(String, Crest::ParamsValue))
    object.each_with_index(1).reduce([] of Tuple(String, Crest::ParamsValue)) do |memo, (item, index)|
      processed_key = parent_key ? "#{parent_key}[#{index}]" : ""

      memo << {processed_key, item}
    end
  end
end

describe "Custom params encoder spec" do
  describe ".flatten_params" do
    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}, {"key2", "123"}]

      CustomParamsEncoder.flatten_params(input).should eq(output)
    end
  end

  describe "#encode" do
    it "encodes complex objects" do
      input = {"a" => ["one", "two", "three"]}
      # "a[1]=one&a[2]=two&a[3]=three"
      output = "a%5B1%5D=one&a%5B2%5D=two&a%5B3%5D=three"

      CustomParamsEncoder.encode(input).should eq(output)
    end
  end

  describe "#decode" do
    it "decodes array" do
      query = "a[1]=one&a[2]=two&a[3]=three"
      params = {"a" => ["one", "two", "three"]}

      CustomParamsEncoder.decode(query).should eq(params)
    end
  end
end
