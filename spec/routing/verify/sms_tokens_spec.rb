require 'spec_helper'

describe "sms_tokens" do
  describe "GET /verify/sms_token" do
    it { expect(get("/verify/sms_token")).to route_to \
         controller: 'verify/sms_tokens',
         action: 'show'
    }
  end

  describe "PUT /verify/sms_token" do
    it { expect(put("/verify/sms_token")).to route_to \
         controller: 'verify/sms_tokens',
         action: 'update'
    }
  end
end
