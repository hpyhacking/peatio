require 'spec_helper'

describe Withdraw do
  subject(:withdraw) { build(:satoshi_withdraw) }

  describe 'sn' do
    before do
      Timecop.freeze(Time.local(2013,10,7,18,18,18))
      @withdraw = create(:satoshi_withdraw, id: 1)
    end

    after do
      Timecop.return
    end

    it "generate right sn" do
      expect(@withdraw.sn).to eq('13100718180001')
    end

    it 'alias withdraw_id to sn' do
      expect(@withdraw.withdraw_id).to eq('13100718180001')
    end
  end

  describe 'after update' do
    [:done, :rejected, :canceled].each do |state|
      it "busts last done withdraw cache when state changes to #{state}" do
        withdraw.save
        key = withdraw.send(:last_completed_withdraw_cache_key)
        Rails.cache.write(key, 123)

        expect{
          withdraw.update_attributes!(aasm_state: state, txid: 'tx123')
        }.to change { Rails.cache.read(key) }.from(123).to(nil)
      end
    end
  end

  context 'account id assignment' do
    subject { build :satoshi_withdraw, account_id: 999 }

    it "don't accept account id from outside" do
      subject.save
      expect(subject.account_id).to eq(subject.member.get_account(subject.currency).id)
    end
  end

  describe 'callbacks', truncation: true do
    subject { build :bank_withdraw, save_fund_source: '1' }

    it 'creates fund source if asked to save_fund_source' do
      expect {
        subject.save
      }.to change(FundSource, :count).by(1)
    end

    it "doesn't create duplicate fund sources" do
      subject.save

      expect {
        create :bank_withdraw,
          save_fund_source: '1',
          fund_uid: subject.fund_uid,
          fund_extra: subject.fund_extra,
          member: subject.member
      }.to change(FundSource, :count).by(0)
    end
  end
end
