require 'spec_helper'

describe Withdraw do

  context '#fix_precision' do
    it "should round down to max precision" do
      withdraw = create(:satoshi_withdraw, sum: '0.123456789')
      withdraw.sum.should == '0.12345678'.to_d
    end
  end

  context 'fund source' do
    it "should strip trailing spaces in fund_uid" do
      fund_source = create(:btc_fund_source, uid: 'test   ')
      @withdraw = create(:satoshi_withdraw, fund_source_id: fund_source.id)
      @withdraw.fund_uid.should == 'test'
    end
  end

  context 'bank withdraw' do
    describe "#audit!" do
      subject { create(:bank_withdraw) }
      before  { subject.submit! }

      it "should accept withdraw with clean history" do
        subject.audit!
        subject.should be_accepted
      end

      it "should mark withdraw with suspicious history" do
        subject.account.versions.delete_all
        subject.audit!
        subject.should be_suspect
      end

      it "should approve quick withdraw directly" do
        subject.update_attributes sum: 5
        subject.audit!
        subject.should be_processing
      end
    end
  end

  context 'coin withdraw' do
    describe '#audit!' do
      subject { create(:satoshi_withdraw) }

      before do
        subject.submit!
      end

      it "should be rejected if address is invalid" do
        CoinRPC.stubs(:[]).returns(mock('rpc', validateaddress: {isvalid: false}))
        subject.audit!
        subject.should be_rejected
      end

      it "should be rejected if address belongs to hot wallet" do
        CoinRPC.stubs(:[]).returns(mock('rpc', validateaddress: {isvalid: true, ismine: true}))
        subject.audit!
        subject.should be_rejected
      end

      it "should accept withdraw with clean history" do
        CoinRPC.stubs(:[]).returns(mock('rpc', validateaddress: {isvalid: true}))
        subject.audit!
        subject.should be_accepted
      end

      it "should mark withdraw with suspicious history" do
        CoinRPC.stubs(:[]).returns(mock('rpc', validateaddress: {isvalid: true}))
        subject.account.versions.delete_all
        subject.audit!
        subject.should be_suspect
      end

      it "should approve quick withdraw directly" do
        CoinRPC.stubs(:[]).returns(mock('rpc', validateaddress: {isvalid: true}))
        subject.update_attributes sum: '0.099'
        subject.audit!
        subject.should be_processing
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

    describe 'account id assignment' do
      subject { build :satoshi_withdraw, account_id: 999 }

      it "don't accept account id from outside" do
        subject.save
        expect(subject.account_id).to eq(subject.member.get_account(subject.currency).id)
      end
    end
  end

  context 'Worker::WithdrawCoin#process' do
    subject { create(:satoshi_withdraw) }
    before do
      @rpc = mock()
      @rpc.stubs(getbalance: 50000, sendtoaddress: '12345', settxfee: true )
      @broken_rpc = mock()
      @broken_rpc.stubs(getbalance: 5)

      subject.submit
      subject.accept
      subject.process
      subject.save!
    end

    it 'transitions to :almost_done after calling rpc but getting Exception' do
      CoinRPC.stubs(:[]).returns(@broken_rpc)

      lambda { Worker::WithdrawCoin.new.process({id: subject.id}, {}, {}) }.should raise_error(Account::BalanceError)

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

