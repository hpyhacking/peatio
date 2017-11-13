describe WithdrawMailer do
  describe 'withdraw_state' do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.cancel!
      WithdrawMailer.withdraw_state(withdraw.id)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('[Peatio] Your withdraw state update')
      expect(mail.to).to eq([withdraw.member.email])
      expect(mail.from).to eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('canceled')
    end
  end

  describe 'submitted' do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.submit!
      WithdrawMailer.submitted(withdraw.id)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('[Peatio] Your withdraw state update')
      expect(mail.to).to eq([withdraw.member.email])
      expect(mail.from).to eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('submitted')
    end
  end

  describe 'done' do
    let(:withdraw) { create :satoshi_withdraw }
    let(:mail) do
      withdraw.submit!
      withdraw.accept!
      withdraw.process!
      withdraw.succeed!
      WithdrawMailer.done(withdraw.id)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('[Peatio] Your withdraw state update')
      expect(mail.to).to eq([withdraw.member.email])
      expect(mail.from).to eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('complete')
    end
  end
end
