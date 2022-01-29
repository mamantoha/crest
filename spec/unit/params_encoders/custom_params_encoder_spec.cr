require "../../spec_helper"

# EnumeratedFlatParamsEncoder
class CustomParamsEncoder < Crest::ParamsEncoder
  alias Type = Nil | String | Array(Type) | Hash(String, Type)

  SUBKEYS_REGEX = /[^\[\]]+(?:\]?\[\])?/
  ARRAY_REGEX   = /[\[\]]+\Z/

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
    params = {} of String => Type

    query.split('&').each do |pair|
      next if pair.empty?

      key, value = pair.split('=', 2)
      key = URI.decode(key)
      value = URI.decode(value)
      decode_pair(key, value, params)
    end

    dehash(params).as(Hash)
  end

  private def decode_pair(key : String, value : String, context : Hash(String, Type))
    subkeys = key.scan(SUBKEYS_REGEX)

    subkeys.each_with_index do |subkey, i|
      is_array = false

      last_subkey = (i == subkeys.size - 1)
      subkey = subkey[0]

      if (match = subkey.match(ARRAY_REGEX))
        is_array = true
        subkey = match.pre_match
      end

      context = prepare_context(context, subkey, is_array, last_subkey)
      add_to_context(is_array, context, value, subkey) if last_subkey
    end
  end

  private def prepare_context(context, subkey : String, is_array : Bool, last_subkey : Bool)
    if !last_subkey || is_array
      context = new_context(subkey, is_array, context) if context.is_a?(Hash)
    end

    if context.is_a?(Array) && !is_array
      context = match_context(context, subkey)
    end

    context
  end

  private def new_context(subkey, is_array : Bool, context)
    value_type = is_array ? Array(Type) : Hash(String, Type)

    context[subkey] ||= value_type.new
  end

  def match_context(context, subkey)
    context << {} of String => Type if !context.last?.is_a?(Hash) || context.last.as(Hash).has_key?(subkey)
    context.last?
  end

  private def add_to_context(is_array : Bool, context, value : String, subkey : String)
    is_array ? (context.as(Array) << value) : (context.as(Hash)[subkey] = value)
  end

  # Converts a nested hash with purely numeric keys into an array.
  private def dehash(hash, depth = 0) : Array(Type) | Hash(String, Type)
    hash.each do |key, value|
      hash[key] = dehash(value, depth + 1) if value.is_a?(Hash)
    end

    if depth.positive? && !hash.empty? && hash.keys.all? { |k| k =~ /^\d+$/ }
      hash.map(&.last)
    else
      hash
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

      case item
      when Hash
        memo += flatten_params(item, processed_key)
      else
        memo << {processed_key, item}
      end
    end
  end
end

describe "Custom params encoder spec" do
  describe ".flatten_params" do
    it "transform hash param" do
      input = {"first_name" => "Thomas", "last_name" => "Anders"}
      output = [{"first_name", "Thomas"}, {"last_name", "Anders"}]

      CustomParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array" do
      input = {:key1 => {:arr => ["1", "2", "3"]}, :key2 => "123"}
      output = [{"key1[arr][1]", "1"}, {"key1[arr][2]", "2"}, {"key1[arr][3]", "3"}, {"key2", "123"}]

      CustomParamsEncoder.flatten_params(input).should eq(output)
    end

    it "transform nested param with array of hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      output = [{"routes[1][from]", "A"}, {"routes[1][to]", "B"}, {"routes[2][from]", 1}, {"routes[2][to]", 2}]

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

    it "encodes array with hashes" do
      input = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => 1, "to" => 2}]}
      # "routes[1][from]=A&routes[1][to]=B&routes[2][from]=1&routes[2][to]=2"
      output = "routes%5B1%5D%5Bfrom%5D=A&routes%5B1%5D%5Bto%5D=B&routes%5B2%5D%5Bfrom%5D=1&routes%5B2%5D%5Bto%5D=2"

      CustomParamsEncoder.encode(input).should eq(output)
    end
  end

  describe "#decode" do
    it "decodes array" do
      # query = "a[1]=one&a[2]=two&a[3]=three"
      query = "a[]=one&a[]=two&a[]=three"
      params = {"a" => ["one", "two", "three"]}

      CustomParamsEncoder.decode(query).should eq(params)
    end

    it "decodes array with hashes" do
      query = "routes[1][from]=A&routes[1][to]=B&routes[2][from]=X&routes[2][to]=Y"
      # query = "routes[][from]=A&routes[][to]=B&routes[][from]=X&routes[][to]=Y"
      params = {"routes" => [{"from" => "A", "to" => "B"}, {"from" => "X", "to" => "Y"}]}

      # CustomParamsEncoder.decode(query)
      CustomParamsEncoder.decode(query).should eq(params)
    end
  end
end
