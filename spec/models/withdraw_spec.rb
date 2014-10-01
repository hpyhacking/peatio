require 'spec_helper'

describe Withdraw do

  context 'fund source' do
    it "should strip trailing spaces in fund_uid" do
      fund_source = create(:btc_fund_source, uid: 'test   ')
      @withdraw = create(:satoshi_withdraw, fund_source: fund_source)
      @withdraw.fund_uid.should == 'test'
    end
  end

  context 'coin withdraw' do
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

    describe 'account id assignment' do
      subject { build :satoshi_withdraw, account_id: 999 }

      it "don't accept account id from outside" do
        subject.save
        expect(subject.account_id).to eq(subject.member.get_account(subject.currency).id)
      end
    end
  end

  context 'aasm_state' do
    subject { create(:bank_withdraw, sum: 1000) }

    before do
      subject.stubs(:send_withdraw_confirm_email)
    end

    it 'initializes with state :submitting' do
      expect(subject.submitting?).to be_true
    end

    it 'transitions to :submitted after calling #submit!' do
      subject.submit!

      expect(subject.submitted?).to be_true
      expect(subject.sum).to eq subject.account.locked
      expect(subject.sum).to eq subject.account_versions.last.locked
    end

    it 'transitions to :rejected after calling #reject!' do
      subject.submit!
      subject.accept!
      subject.reject!

      expect(subject.rejected?).to be_true
    end

    context :process do
      before do
        subject.submit!
        subject.accept!
      end

      it 'transitions to :processing after calling #process! when withdrawing fiat currency' do
        subject.stubs(:coin?).returns(false)

        subject.process!

        expect(subject.processing?).to be_true
      end

      it 'transitions to :failed after calling #fail! when withdrawing fiat currency' do
        subject.stubs(:coin?).returns(false)

        subject.process!

        expect { subject.fail! }.to_not change{subject.account.amount}

        expect(subject.failed?).to be_true
      end

      it 'transitions to :processing after calling #process!' do
        subject.expects(:send_coins!)

        subject.process!

        expect(subject.processing?).to be_true
      end

      context 'Worker::WithdrawCoin#process' do
        before do
          @rpc = mock()
          @rpc.stubs(getbalance: 50000, sendtoaddress: '12345', settxfee: true )
          @broken_rpc = mock()
          @broken_rpc.stubs(getbalance: 5)

          subject.expects(:send_coins!)
          subject.process!
        end

        it 'transitions to :almost_done after calling rpc but getting Exception' do
          CoinRPC.stubs(:[]).returns(@broken_rpc)

          begin Worker::WithdrawCoin.new.process({id: subject.id}, {}, {}); rescue; end

          expect(subject.reload.almost_done?).to be_true
        end

        it 'transitions to :done after calling rpc' do
          CoinRPC.stubs(:[]).returns(@rpc)

          expect { Worker::WithdrawCoin.new.process({id: subject.id}, {}, {}) }.to change{subject.account.reload.amount}.by(-subject.sum)

          subject.reload
          expect(subject.done?).to be_true
          expect(subject.txid).to eq('12345')
        end

        it 'does not send coins again if previous attempt failed' do
          CoinRPC.stubs(:[]).returns(@broken_rpc)
          begin Worker::WithdrawCoin.new.process({id: subject.id}, {}, {}); rescue; end
          CoinRPC.stubs(:[]).returns(mock())

          expect { Worker::WithdrawCoin.new.process({id: subject.id}, {}, {}) }.to_not change{subject.account.reload.amount}
          expect(subject.reload.almost_done?).to be_true
        end
      end
    end

    context :cancel do
      it 'transitions to :canceled after calling #cancel!' do
        subject.cancel!

        expect(subject.canceled?).to be_true
        expect(subject.account.locked).to eq 0
      end

      it 'transitions from :submitted to :canceled after calling #cancel!' do
        subject.submit!
        subject.cancel!

        expect(subject.canceled?).to be_true
        expect(subject.account.locked).to eq 0
      end

      it 'transitions from :accepted to :canceled after calling #cancel!' do
        subject.submit!
        subject.accept!
        subject.cancel!

        expect(subject.canceled?).to be_true
        expect(subject.account.locked).to eq 0
      end
    end
  end

  context "#quick?" do
    subject(:withdraw) { build(:satoshi_withdraw) }

    it "returns false if currency doesn't set quick withdraw max" do
      withdraw.should_not be_quick
    end

    it "returns false if exceeds quick withdraw amount" do
      withdraw.currency_obj.stubs(:quick_withdraw_max).returns(withdraw.sum-1)
      withdraw.should_not be_quick
    end

    it "returns true" do
      withdraw.currency_obj.stubs(:quick_withdraw_max).returns(withdraw.sum+1)
      withdraw.should be_quick
    end
  end

end

