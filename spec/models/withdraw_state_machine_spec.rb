require 'spec_helper'

describe Withdraw do
  subject { create(:bank_withdraw, sum: 1000) }

  before do
    subject.stubs(:send_withdraw_confirm_email)
    AMQPQueue.stubs(:enqueue)
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

  it 'transitions to :accepted with normal account after calling #submit!' do
    subject.submit!

    Worker::WithdrawAudit.new.process(id: subject.id)

    expect(subject.reload.accepted?).to be_true
  end

  it 'transitions to :suspect with suspect account after calling #submit!' do
    subject.account.update_attribute(:balance, 1000.to_d)
    subject.submit!

    Worker::WithdrawAudit.new.process(id: subject.id)

    expect(subject.reload.suspect?).to be_true
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

        begin Worker::WithdrawCoin.new.process(id: subject.id); rescue; end

        expect(subject.reload.almost_done?).to be_true
      end

      it 'transitions to :done after calling rpc' do
        CoinRPC.stubs(:[]).returns(@rpc)

        expect { Worker::WithdrawCoin.new.process(id: subject.id) }.to change{subject.account.reload.amount}.by(-subject.sum)

        subject.reload
        expect(subject.done?).to be_true
        expect(subject.txid).to eq('12345')
      end

      it 'does not send coins again if previous attempt failed' do
        CoinRPC.stubs(:[]).returns(@broken_rpc)
        begin Worker::WithdrawCoin.new.process(id: subject.id); rescue; end
        CoinRPC.stubs(:[]).returns(mock())

        expect { Worker::WithdrawCoin.new.process(id: subject.id) }.to_not change{subject.account.reload.amount}
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
