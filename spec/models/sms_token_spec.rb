require 'spec_helper'

describe SmsToken do

  describe "#generate_token" do
    let(:member) { create :member }
    let(:sms_token) { create :sms_token, member: member }

    it "generate token before save" do
      expect(sms_token.token).not_to be_blank
    end

    it "generate 6-dig number token" do
      expect(sms_token.token.length).to eq(6)
    end
  end

end
