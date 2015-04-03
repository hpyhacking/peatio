require 'spec_helper'

describe "sms_auths" do
  describe "GET /verify/sms_auth" do
    it { expect(get("/verify/sms_auth")).to be_routable }
  end

  describe "PUT /verify/sms_auth" do
    it { expect(put("/verify/sms_auth")).to be_routable }
  end
end
