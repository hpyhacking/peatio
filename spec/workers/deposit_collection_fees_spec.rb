# encoding: UTF-8
# frozen_string_literal: true

describe Workers::AMQP::DepositCollectionFees do
  let(:deposit) do
    create(:deposit, :deposit_trst).tap { |d| d.accept! }
  end
  let(:wallet) { Wallet.find_by_blockchain_key('eth-rinkeby') }
  let(:wallet_service) { WalletService.new(wallet) }
  let(:txid) { Faker::Lorem.characters(64) }
  let(:spread) do
    [{ to_address: 'to-address', amount: 0.1, status: 'pending' }]
  end

  before do
    spread_deposit_res = spread.map { |s| Peatio::Transaction.new(s) }
    WalletService.any_instance
                  .expects(:spread_deposit)
                  .with(instance_of(Deposits::Coin))
                  .returns(spread_deposit_res)

    deposit_collection_fees_res = [Peatio::Transaction.new(amount: 1, currency_id: :bbtc, hash: 'hash')]
    WalletService.any_instance
                  .expects(:deposit_collection_fees!)
                  .with(instance_of(Deposits::Coin), anything)
                  .returns(deposit_collection_fees_res)
  end

  it 'calls spread_deposit, deposit_collection_fees! and returns true' do
    expect(Workers::AMQP::DepositCollectionFees.new.process(deposit)).to be_truthy
  end

  it 'updates deposit spread' do
    expect(deposit.spread).to eq([])
    expect{ Workers::AMQP::DepositCollectionFees.new.process(deposit) }.to change{deposit.reload.spread}
    expect(deposit.reload.spread).to eq(spread)
  end
end
