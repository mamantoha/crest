require "../spec_helper"

describe Crest::JSONForm do
  describe "#generate" do
    it "generates nested JSON" do
      input = {
        "user" => {
          "name"   => "John",
          "active" => true,
          "roles"  => ["admin", "editor"],
        },
      }

      form = Crest::JSONForm.generate(input, Crest::FlatParamsEncoder)

      form.content_type.should eq("application/json")
      JSON.parse(form.form_data).should eq(JSON.parse(input.to_json))
    end

    it "rejects a direct IO value" do
      error = expect_raises ArgumentError do
        Crest::JSONForm.generate({"file" => IO::Memory.new("content")}, Crest::FlatParamsEncoder)
      end

      error.message.should eq("IO values cannot be encoded as JSON; use multipart or a raw request body")
    end

    it "rejects a nested IO value" do
      error = expect_raises ArgumentError do
        Crest::JSONForm.generate(
          {"payload" => {"file" => IO::Memory.new("content")}},
          Crest::FlatParamsEncoder
        )
      end

      error.message.should eq("IO values cannot be encoded as JSON; use multipart or a raw request body")
    end
  end
end
