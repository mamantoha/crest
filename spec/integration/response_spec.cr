require "../spec_helper"

describe Crest::Response do
  it "response instance should respond to helper methods" do
    response = Crest.get("#{TEST_SERVER_URL}")
    (response.body).should eq("Hello World!")
    (response.invalid?).should be_false
    (response.informational?).should be_false
    (response.successful?).should be_true
    (response.redirection?).should be_false
    (response.redirect?).should be_false
    (response.client_error?).should be_false
    (response.server_error?).should be_false
  end
end
