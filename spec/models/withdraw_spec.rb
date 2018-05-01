describe Withdraw do
  describe '#fix_precision' do
    it 'should round down to max precision' do
      withdraw = create(:btc_withdraw, sum: '0.123456789')
      expect(withdraw.sum).to eq('0.12345678'.to_d)
    end
  end

  context 'bank withdraw' do
    describe '#audit!' do
      subject { create(:usd_withdraw) }
      before  { subject.submit! }

      it 'should accept withdraw with clean history' do
        subject.audit!
        expect(subject).to be_accepted
      end

      it 'should mark withdraw with suspicious history' do
        subject.account.versions.delete_all
        subject.audit!
        expect(subject).to be_suspected
      end

      it 'should accept quick withdraw directly' do
        subject.update_attributes sum: 5
        subject.audit!
        expect(subject).to be_accepted
      end
    end
  end

  context 'coin withdraw' do
    describe '#audit!' do
      subject { create(:btc_withdraw) }
      before { subject.submit! }

      it 'should be rejected if address is invalid' do
        CoinAPI.stubs(:[]).returns(mock('rpc', inspect_address!: { is_valid: false }))
        subject.audit!
        expect(subject).to be_rejected
      end

      context 'internal recipient' do
        let(:payment_address) { create(:btc_payment_address) }
        subject { create(:btc_withdraw, rid: payment_address.address) }

        around do |example|
          WebMock.disable_net_connect!
          example.run
          WebMock.allow_net_connect!
        end

        let :request_body do
          { jsonrpc: '1.0',
            method:  'validateaddress',
            params:  [payment_address.address]
          }.to_json
        end

        let(:response_body) { '{"result":{"isvalid":true,"ismine":true}}' }

        before do
          stub_request(:post, 'http://127.0.0.1:18332').with(body: request_body).to_return(body: response_body)
        end

        it 'permits withdraw to address which belongs to Peatio' do
          subject.audit!
          expect(subject).to be_accepted
        end
      end

      it 'should accept withdraw with clean history' do
        CoinAPI.stubs(:[]).returns(mock('rpc', inspect_address!: { is_valid: true }))
        subject.audit!
        expect(subject).to be_accepted
      end

      it 'should mark withdraw with suspicious history' do
        CoinAPI.stubs(:[]).returns(mock('rpc', inspect_address!: { is_valid: true }))
        subject.account.versions.delete_all
        subject.audit!
        expect(subject).to be_suspected
      end

      it 'should approve quick withdraw directly' do
        CoinAPI.stubs(:[]).returns(mock('rpc', inspect_address!: { is_valid: true }))
        subject.update_attributes sum: '0.099'
        subject.audit!
        expect(subject).to be_processing
      end
    end

    describe 'account id assignment' do
      subject { build :btc_withdraw, account_id: 999 }

      it 'don\'t accept account id from outside' do
        subject.save
        expect(subject.account_id).to eq(subject.member.get_account(subject.currency).id)
      end
    end
  end

  context 'Worker::WithdrawCoin#process' do
    subject { create(:btc_withdraw) }
    before do
      @rpc = mock
      @rpc.stubs(load_balance!: 50_000, create_withdrawal!: '12345')
      @broken_rpc = CoinAPI
      @broken_rpc.stubs(load_balance!: 5)

      subject.submit
      subject.accept
      subject.process
      subject.save!

    end

    it 'transitions to :failed after calling rpc but getting Exception' do
      CoinAPI.stubs(:[]).raises(CoinAPI::Error)

      Worker::WithdrawCoin.new.process({ id: subject.id })

      expect(subject.reload.failed?).to be true
    end

    it 'transitions to :succeed after calling rpc' do
      CoinAPI.stubs(:[]).returns(@rpc)

      expect { Worker::WithdrawCoin.new.process({ id: subject.id }) }.to change { subject.account.reload.amount }.by(-subject.sum)

      subject.reload
      expect(subject.succeed?).to be true
      expect(subject.txid).to eq('12345')
    end

    it 'does not send coins again if previous attempt failed' do
      CoinAPI.stubs(:[]).raises(CoinAPI::Error)
      begin Worker::WithdrawCoin.new.process({ id: subject.id }); rescue; end
      CoinAPI.stubs(:[]).returns(CoinAPI::BTC)

      expect { Worker::WithdrawCoin.new.process({ id: subject.id }) }.to_not change { subject.account.reload.amount }
      expect(subject.reload.failed?).to be true
    end

    it 'unlocks coins after calling rpc but getting Exception' do
      CoinAPI.stubs(:[]).raises(CoinAPI::Error)

      expect { Worker::WithdrawCoin.new.process({ id: subject.id }) }
          .to change { subject.account.reload.locked }.by(-subject.sum)
          .and change { subject.account.reload.balance }.by(subject.sum)
    end
  end

  context 'aasm_state' do
    subject { create(:usd_withdraw, sum: 1000) }

    before do
      subject.stubs(:send_withdraw_confirm_email)
    end

    it 'initializes with state :prepared' do
      expect(subject.prepared?).to be true
    end

    it 'transitions to :submitted after calling #submit!' do
      subject.submit!
      expect(subject.submitted?).to be true
      expect(subject.sum).to eq subject.account.locked
      expect(subject.sum).to eq subject.account_versions.last.locked
    end

    it 'transitions to :rejected after calling #reject!' do
      subject.submit!
      subject.reject!

      expect(subject.rejected?).to be true
    end

    context :process do
      before { subject.submit! }
      before { subject.accept! }

      it 'transitions to :processing after calling #process! when withdrawing fiat currency' do
        subject.stubs(:coin?).returns(false)

        subject.process!

        expect(subject.processing?).to be true
      end

      it 'transitions to :failed after calling #fail! when withdrawing fiat currency' do
        subject.stubs(:coin?).returns(false)

        subject.process!

        expect { subject.fail! }.to_not change { subject.account.amount }

        expect(subject.failed?).to be true
      end

      it 'transitions to :processing after calling #process!' do
        subject.expects(:send_coins!)

        subject.process!

        expect(subject.processing?).to be true
      end
    end

    context :cancel do
      it 'transitions to :canceled after calling #cancel!' do
        subject.cancel!

        expect(subject.canceled?).to be true
        expect(subject.account.locked).to eq 0
      end

      it 'transitions from :submitted to :canceled after calling #cancel!' do
        subject.submit!
        subject.cancel!

        expect(subject.canceled?).to be true
        expect(subject.account.locked).to eq 0
      end

      it 'transitions from :accepted to :canceled after calling #cancel!' do
        subject.submit!
        subject.accept!
        subject.cancel!

        expect(subject.canceled?).to be true
        expect(subject.account.locked).to eq 0
      end
    end
  end

  context '#quick?' do
    subject(:withdraw) { build(:btc_withdraw) }

    it 'returns false if currency doesn\'t set quick withdraw max' do
      expect(withdraw).to_not be_quick
    end

    it 'returns false if exceeds quick withdraw amount' do
      withdraw.currency.stubs(:quick_withdraw_limit).returns(withdraw.sum - 1)
      expect(withdraw).to_not be_quick
    end

    it 'returns true' do
      withdraw.currency.stubs(:quick_withdraw_limit).returns(withdraw.sum + 1)
      expect(withdraw).to be_quick
    end
  end

  context 'fee is set to fixed value of 10' do
    let(:withdraw) { create(:usd_withdraw, sum: 200) }
    before { Currency.any_instance.expects(:withdraw_fee).once.returns(10) }
    it 'computes fee' do
      expect(withdraw.fee).to eql 10.to_d
      expect(withdraw.amount).to eql 190.to_d
    end
  end

  context 'fee exceeds amount' do
    let(:withdraw) { build(:usd_withdraw, sum: 200) }
    before { Currency.any_instance.expects(:withdraw_fee).once.returns(200) }
    it 'fails validation' do
      expect(withdraw.save).to eq false
      expect(withdraw.errors.full_messages).to eq ['Amount must be greater than 0']
    end
  end

  it 'automatically generates TID if it is blank' do
    expect(create(:btc_withdraw).tid).not_to be_blank
  end

  it 'doesn\'t generate TID if it is not blank' do
    expect(create(:btc_withdraw, tid: 'TID1234567890').tid).to eq 'TID1234567890'
  end

  it 'validates uniqueness of TID' do
    record1 = create(:btc_withdraw)
    record2 = build(:btc_withdraw, tid: record1.tid)
    record2.save
    expect(record2.errors.full_messages.first).to match(/tid has already been taken/i)
  end

  it 'uppercases TID' do
    expect(create(:btc_withdraw, tid: 'tid').tid).to eq 'TID'
  end
end
