require 'spec_helper'

describe Member do
  subject(:member) { build(:member) }

  describe 'sn' do
    subject(:member) { create(:member) }
    it { expect(member.sn).to_not be_nil }
    it { expect(member.sn).to_not be_empty }
    it { expect(member.sn).to match /^PEA.*TIO$/ }
  end

  describe 'before_create' do
    it 'creates accounts for the member' do
      expect {
        member.save!
      }.to change(member.accounts, :count).by(Currency.codes.size)

      Currency.codes.each do |code|
        expect(Account.with_currency(code).where(member_id: member.id).count).to eq 1
      end
    end
  end

  describe 'send activation after create' do
    let(:auth_auth) {
      {
        'info' => { 'email' => 'foobar@peatio.dev' }
      }
    }

    it 'create activation' do
      expect {
        Member.from_auth(auth_auth)
      }.to change(Activation, :count).by(1)
    end
  end
end
