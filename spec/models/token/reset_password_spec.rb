require 'spec_helper'

describe Token::ResetPassword do
  let(:member) { create :member }
  let(:token) { Token::ResetPassword.new email: member.email }

  describe 'create' do
    it {
      expect {
        token.save
      }.to change(Token::ResetPassword, :count).by(1)
    }
    it { expect(token).not_to be_is_used }
  end

  describe 're-create token within 5 minutes' do
    before { token.save }

    it {
      expect {
        Timecop.travel(4.minutes.from_now)
        expect(token.reload).not_to be_expired

        new_token = Token::ResetPassword.create email: member.email
        expect(new_token).not_to be_valid
      }.not_to change(Token::ResetPassword, :count)
    }

  end

  describe 're-create token after 5 minutes' do
    before { token.save }

    it {
      expect {
        Timecop.travel(6.minutes.from_now)
        expect(token.reload).to be_expired

        new_token = Token::ResetPassword.create email: member.email
        expect(new_token).not_to be_expired
        expect(new_token).not_to eq(token)
      }.to change(Token::ResetPassword, :count).by(1)
    }
  end
end
