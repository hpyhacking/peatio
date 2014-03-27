require 'spec_helper'

describe Withdraw do
  subject(:withdraw) { build(:withdraw) }

  describe 'fee' do
    it "default fee is zero" do
      withdraw = build(:withdraw, channel_id: nil, sum: '10'.to_d)
      withdraw.valid?

      expect(withdraw.fee).to be_d '0'
      expect(withdraw.amount).to be_d '10'
    end

    it "bank is have compute" do
      withdraw = build(:withdraw, channel_id: 400, sum: '1000'.to_d)
      withdraw.valid?

      expect(withdraw.fee).to be_d '3'
      expect(withdraw.amount).to be_d '997'
    end

    it "bank is have compute with fix" do
      withdraw = build(:withdraw, channel_id: 400, sum: '1235.232323123'.to_d)
      withdraw.valid?

      expect(withdraw.fee).to be_d '3.70'
      expect(withdraw.amount).to be_d '1231.53'
    end
  end

  describe 'sn' do
    before do
      Timecop.freeze(Time.local(2013,10,7,18,18,18))
      @withdraw = create(:withdraw, currency: 'btc', id: 1)
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
    let(:member) { create :member, identity: identity }

    [:done, :rejected, :canceled].each do |state|
      it "returns the number of withdraws of the same type including itself since last #{state} withdraw" do
        create(:withdraw, aasm_state: state)
        create_list(:withdraw, 2)

        create(:withdraw, :bank, state: :done)
        bank_withdraw = create(:withdraw, :bank)
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
        create_list(:withdraw, 2)
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

  describe 'callbacks' do
    subject { build :bank_withdraw }
    it 'creates fund source if asked to save_fund_source' do
      subject.save_fund_source = '1'

      expect {
        subject.save
      }.to change(FundSource, :count).by(1)
    end
  end
end
