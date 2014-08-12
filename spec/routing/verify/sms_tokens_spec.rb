require 'spec_helper'

describe "sms_tokens" do
  it "get /verify/sms_tokens/new to be routable" do
    expect(get("/verify/sms_tokens/new")).to be_routable
  end

  it "route /verify/sms_tokens/new to verify/sms_tokens#new" do
    expect(get("/verify/sms_tokens/new")).to route_to("verify/sms_tokens#new")
  end

  it "post /verify/sms_tokens to be routable" do
    expect(post("/verify/sms_tokens")).to be_routable
  end

  it "route /verify/sms_tokens to verify/sms_tokens" do
    expect(post("/verify/sms_tokens")).to route_to("verify/sms_tokens#create")
  end
end
