require "spec_helper"

describe MemberMailer do
  describe "notify_signin" do
    let(:member) { create :member }
    let(:mail) { MemberMailer.notify_signin(member.id) }

    it "renders the headers" do
      mail.subject.should eq("[PEATIO] You have just signed in")
      mail.to.should eq([member.email])
      mail.from.should eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it "renders the body" do
      mail.body.encoded.should match("signed in")
    end
  end

end
