# frozen_string_literal: true

describe 'revert.rake' do
  let(:bob) { create(:member, :level_3, email: 'bob@gmail.com') }
  let(:alice) { create(:member, :level_3, email: 'alice@gmail.com') }
  let(:bob_accounting_balance) { Operations::Liability.where(member_id: bob.id).sum(:credit) - Operations::Liability.where(member_id: bob.id).sum(:debit) }
  let(:alice_accounting_balance) { Operations::Liability.where(member_id: alice.id).sum(:credit) - Operations::Liability.where(member_id: alice.id).sum(:debit) }
  let(:bob_legacy_balance) { bob.get_account(:usd).balance }
  let(:alice_legacy_balance) { alice.get_account(:btc).balance }
  subject { Rake::Task['revert:trading_activity'] }

  after(:each) { subject.reenable }

  context 'simple case' do
    let(:price)  { 10.to_d }
    let(:volume) { 5.to_d }
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, :btcusd, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, :btcusd, price: price, volume: volume, member: bob).to_matching_attributes }

    let(:executor) do
      Matching::Executor.new(
        action: 'execute',
        trade: {
          market_id: 'btcusd',
          maker_order_id: ask.id,
          taker_order_id: bid.id,
          strike_price: price.to_s('F'),
          amount: volume.to_s('F'),
          total: (price * volume).to_s('F')
        }
      )
    end

    before do
      # Deposit 5 btc to Alice
      # Deposit 50 usd to Bob
      deposit = create(:deposit_btc, member_id: alice.id, amount: 5)
      deposit.accept!
      deposit.process!
      deposit.dispatch!
      create(:deposit_usd, member_id: bob.id, amount: 50).accept!
      alice.get_account(:btc).lock_funds(5)
      bob.get_account(:usd).lock_funds(50)
      executor.execute!
    end

    it 'revert trading activities' do
      subject.invoke(bob.email)
      expect(alice_legacy_balance).to eq(5)
      expect(bob_legacy_balance).to eq(50)
      expect(Operations.validate_accounting_equation(Operations::Liability.all +
        Operations::Asset.all +
        Operations::Revenue.all +
        Operations::Expense.all)).to eq(true)
      expect(alice_legacy_balance).to eq(alice_accounting_balance)
      expect(bob_legacy_balance).to eq(bob_accounting_balance)
    end
  end

  context 'several trades' do
    let(:price) { 10.to_d }
    let(:volume) { 5.to_d }
    let(:volume1) { 3.to_d }
    let(:volume2) { 2.to_d }
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, :btcusd, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, :btcusd, price: price, volume: volume1, member: bob).to_matching_attributes }
    let(:bid1) { ::Matching::LimitOrder.new create(:order_bid, :btcusd, price: price, volume: volume2, member: bob).to_matching_attributes }

    let(:executor1) do
      Matching::Executor.new(
        action: 'execute',
        trade: {
          market_id: 'btcusd',
          maker_order_id: ask.id,
          taker_order_id: bid.id,
          strike_price: price.to_s('F'),
          amount: volume1.to_s('F'),
          total: (price * volume1).to_s('F')
        }
      )
    end

    let(:executor2) do
      Matching::Executor.new(
        action: 'execute',
        trade: {
          market_id: 'btcusd',
          maker_order_id: ask.id,
          taker_order_id: bid1.id,
          strike_price: price.to_s('F'),
          amount: volume2.to_s('F'),
          total: (price * volume2).to_s('F')
        }
      )
    end

    before do
      # Deposit 5 btc to Alice
      # Deposit 50 usd to Bob
      deposit = create(:deposit_btc, member_id: alice.id, amount: 5)
      deposit.accept!
      deposit.process!
      deposit.dispatch!
      create(:deposit_usd, member_id: bob.id, amount: 50).accept!
      alice.get_account(:btc).lock_funds(5)
      bob.get_account(:usd).lock_funds(50)
      executor1.execute!
      executor2.execute!
    end

    it 'reverts trading activities' do
      subject.invoke(bob.email)
      expect(alice_legacy_balance).to eq(5)
      expect(bob_legacy_balance).to eq(50)
      expect(Operations.validate_accounting_equation(Operations::Liability.all +
             Operations::Asset.all +
             Operations::Revenue.all +
             Operations::Expense.all)).to eq(true)
      expect(alice_legacy_balance).to eq(alice_accounting_balance)
      expect(bob_legacy_balance).to eq(bob_accounting_balance)
    end
  end
end
