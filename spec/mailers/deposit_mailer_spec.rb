require "spec_helper"

describe DepositMailer do

  describe "accepted" do
    let(:deposit) { create :deposit }
    let(:mail) {
      deposit.submit!
      deposit.accept!
      DepositMailer.accepted(deposit.id)
    }

    it { expect(mail).not_to be_nil }
    it { expect(mail.subject).to match "Your deposit has been credited into your account" }
  end

end
