require 'spec_helper'

describe Token::Activation do
  let(:member) { create :member }
  let(:activation) { create :activation, member: member }

  describe '#confirm!' do
    before { activation.confirm! }

    it { expect(member).to be_activated }
  end

  describe 'send_token after creation' do
    let(:mail) { ActionMailer::Base.deliveries.last }

    before { activation }

    it { expect(mail.subject).to match('Account Activation') }
  end

end
