describe DepositMailer do
  describe 'accepted' do
    let(:deposit) { create :deposit }
    let(:mail) do
      deposit.submit!
      deposit.accept!
      DepositMailer.accepted(deposit.id)
    end

    it { expect(mail).not_to be_nil }
    it { expect(mail.subject).to match 'Your deposit has been credited into your account' }
  end
end
