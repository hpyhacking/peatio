require 'spec_helper'

describe Withdraw do
  subject(:withdraw) { build(:satoshi_withdraw) }

  describe 'fee' do
    it "computes fee for bank" do
      withdraw = build(:bank_withdraw, sum: '1000'.to_d)
      fee = withdraw.channel.fee * withdraw.sum
      amount = withdraw.sum - fee

      expect(withdraw.valid?).to be_true
      expect(withdraw.fee).to be_d fee
      expect(withdraw.amount).to be_d amount
    end

    it "computes fee for bank and limits the fraction length" do
      withdraw = build(:bank_withdraw, sum: '1235.232323123'.to_d)
      sum = withdraw.sum.round(withdraw.channel.fixed, :floor)
      fee = (withdraw.channel.fee * sum).round(withdraw.channel.fixed, :floor)
      amount = sum - fee

      expect(withdraw.valid?).to be_true
      expect(withdraw.fee).to be_d fee
      expect(withdraw.amount).to be_d amount
    end
  end

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

  describe 'position_in_queue' do
    [:done, :rejected, :canceled].each do |state|
      it "returns the number of withdraws of the same type including itself since last #{state} withdraw" do
        create(:satoshi_withdraw, aasm_state: state)
        create_list(:satoshi_withdraw, 2)

        create(:bank_withdraw, state: :done)
        bank_withdraw = create(:bank_withdraw)
        expect(bank_withdraw.position_in_queue).to eq(1)

        withdraw.save!
        expect(withdraw.position_in_queue).to eq(3)
      end

      context "when the withdraw itself has the completed state: #{state}" do
        it "returns 0" do
          withdraw.aasm_state = state
          withdraw.save!

          expect(withdraw.position_in_queue).to eq(0)
        end
      end
    end

    it 'stores the last completed withdraw id in cache' do
      withdraw.save!

      described_class.expects(:completed).once.
        returns(described_class.all)

      withdraw.position_in_queue
      withdraw.position_in_queue
    end

    context 'when there is no withdraw of the same type with :done status' do
      it 'returns all pending transactions of the same type' do
        create_list(:satoshi_withdraw, 2)
        withdraw.save!

        expect(withdraw.position_in_queue).to eq(3)
      end
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
