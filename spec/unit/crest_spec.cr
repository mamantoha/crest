require "../spec_helper"

describe Crest::VERSION do
  it "should have version" do
    (Crest::VERSION).should_not be_nil
  end
end
