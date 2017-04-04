require "../spec_helper"

describe Crest do
  it "do GET request" do
    response = Crest.get("http://localhost")
  end

  it "do POST request" do
    response = Crest.post("http://localhost", {:foo => "bar"})
  end
end
