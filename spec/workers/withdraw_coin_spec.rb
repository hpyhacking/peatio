# encoding: UTF-8
# frozen_string_literal: true

describe Workers::AMQP::WithdrawCoin do
  let(:member) { create(:member, :barong) }
  let(:withdrawal) { create(:btc_withdraw, :with_deposit_liability) }
  let(:processing_withdrawal) do
    create(:btc_withdraw, :with_deposit_liability)
      .tap(&:accept!)
      .tap(&:process!)
  end

  context 'withdrawal does not exist' do
    before { Withdraw.expects(:find_by_id).returns(nil) }

    it 'returns nil' do
      expect(Workers::AMQP::WithdrawCoin.new.process(withdrawal.as_json)).to be(nil)
    end
  end

  context 'withdrawal is not in processing state' do
    it 'returns nil' do
      expect(Workers::AMQP::WithdrawCoin.new.process(withdrawal.as_json)).to be(nil)
    end
  end

  context 'withdrawal with empty rid' do
    before do
      # withdrawal.submit!
      # withdrawal.accept!
      # withdrawal.process!
      #
      # Withdraws::Coin.any_instance
      #                .expects(:rid)
      #                .with(anything)
      #                .twice
      #                .returns('')

    end

    # TODO: Finalize me.
    it 'returns nil and fail withdrawal' do
      # expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be(nil)
      # expect(processing_withdrawal.reload.failed?).to be_truthy
    end
  end

  context 'hot wallet does not exist' do
    before do
      processing_withdrawal
      Wallet.expects(:active)
            .returns(Wallet.none)
    end

    it 'returns nil and skip withdrawal' do
      expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be(nil)
      expect(processing_withdrawal.reload.skipped?).to be_truthy
    end
  end

  context 'WalletService2 raises error' do
    before do
      WalletService.any_instance.expects(:load_balance!)
                   .returns(100)
      WalletService.any_instance.expects(:build_withdrawal!)
                   .raises(Peatio::Wallet::Registry::NotRegisteredAdapterError)
    end

    it 'returns true and marks withdrawal as errored' do
      expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be_truthy
      expect(processing_withdrawal.reload.errored?).to be_truthy
    end
  end

  context 'wallet balance is not sufficient' do
    before do
      WalletService.any_instance
                   .expects(:load_balance!)
                   .returns(withdrawal.amount * 0.9)
    end

    it 'returns nil and skip withdrawal' do
      expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be(true)
      expect(processing_withdrawal.reload.skipped?).to be_truthy
    end
  end

  context 'wallet balance is sufficient but build_withdrawal! raises error' do
    before do
      WalletService.any_instance
                   .expects(:load_balance!)
                   .returns(withdrawal.amount)

      WalletService.any_instance
                   .expects(:build_withdrawal!)
                   .with(instance_of(Withdraws::Coin))
                   .raises(Peatio::Blockchain::ClientError)
    end

    it 'returns true and marks withdrawal as errored' do
      expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be_truthy
      expect(processing_withdrawal.reload.errored?).to be_truthy
    end
  end

  context 'wallet balance is sufficient and build_withdrawal! returns transaction' do
    before do
      WalletService.any_instance
                   .expects(:load_balance!)
                   .returns(withdrawal.amount)

      transaction = Peatio::Transaction.new(amount: withdrawal.amount,
                                            to_address: withdrawal.rid,
                                            hash: 'hash-1')
      WalletService.any_instance
                   .expects(:build_withdrawal!)
                   .with(instance_of(Withdraws::Coin))
                   .returns(transaction)
    end

    it 'returns true and dispatch withdrawal' do
      expect(Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)).to be_truthy
      expect(processing_withdrawal.reload.confirming?).to be_truthy
      expect(processing_withdrawal.txid).to eq('hash-1')
    end
  end

  context 'transaction with remote_id field' do
    before do
      WalletService.any_instance
                   .expects(:load_balance!)
                   .returns(withdrawal.amount)

      transaction = Peatio::Transaction.new(amount: withdrawal.amount,
                                            to_address: withdrawal.rid,
                                            options: {
                                              'remote_id': 'd12331-12312d-34234'
                                            }.stringify_keys)

      WalletService.any_instance
                   .expects(:build_withdrawal!)
                   .with(instance_of(Withdraws::Coin))
                   .returns(transaction)
    end

    it 'returns true and dispatch withdrawal' do
      Workers::AMQP::WithdrawCoin.new.process(processing_withdrawal.as_json)
      expect(processing_withdrawal.reload.under_review?).to be_truthy
      expect(processing_withdrawal.remote_id).to eq('d12331-12312d-34234')
    end
  end
end
