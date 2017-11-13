describe MemberMailer do
  describe 'notify_signin' do
    let(:member) { create :member }
    let(:mail) { MemberMailer.notify_signin(member.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq('[PEATIO] You have just signed in')
      expect(mail.to).to eq([member.email])
      expect(mail.from).to eq([ENV['SYSTEM_MAIL_FROM']])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('signed in')
    end
  end
end
