require "spec_helper"

describe WithdrawMailer do
  describe "withdraw_state" do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.cancel!
      WithdrawMailer.withdraw_state(withdraw.id)
    end

    it "renders the headers" do
      mail.subject.should eq("[Peatio] Your withdraw state update")
      mail.to.should eq([withdraw.member.email])
      mail.from.should eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it "renders the body" do
      mail.body.encoded.should match("canceled")
    end
  end

  describe "submitted" do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.submit!
      WithdrawMailer.submitted(withdraw.id)
    end

    it "renders the headers" do
      mail.subject.should eq("[Peatio] Your withdraw state update")
      mail.to.should eq([withdraw.member.email])
      mail.from.should eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it "renders the body" do
      mail.body.encoded.should match("submitted")
    end
  end

  describe "done" do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.submit!
      withdraw.accept!
      withdraw.process!
      withdraw.succeed!
      WithdrawMailer.done(withdraw.id)
    end

    it "renders the headers" do
      mail.subject.should eq("[Peatio] Your withdraw state update")
      mail.to.should eq([withdraw.member.email])
      mail.from.should eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it "renders the body" do
      mail.body.encoded.should match("complete")
    end
  end
end
