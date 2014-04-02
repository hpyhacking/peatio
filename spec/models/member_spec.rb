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

      Currency.codes.each do |key, code|
        expect(Account.where(member_id: member.id, currency: code).count).to eq 1
      end
    end
  end
end
