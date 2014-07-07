require "spec_helper"

describe WithdrawMailer do
  describe "withdraw_state" do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.cancel!
      WithdrawMailer.withdraw_state(withdraw.id)
    end

    it "renders the headers" do
      mail.subject.should eq("Your withdraw state")
      mail.to.should eq([withdraw.member.email])
      mail.from.should eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it "renders the body" do
      mail.body.encoded.should match("canceled")
    end
  end

end
