describe 'Accounting' do
  let(:seller) { create(:member, :level_3, :barong) }
  let(:buyer) { create(:member, :level_3, :barong) }

  let :order_ask do
    create :order_ask, \
       bid:           :usd,
       ask:           :btc,
       market:        Market.find_spot_by_symbol(:btcusd),
       state:         :wait,
       ord_type:      :limit,
       price:         '1'.to_d,
       volume:        '10000.0',
       origin_volume: '10000.0',
       locked:        '10000',
       origin_locked: '10000',
       member:        seller
  end

  let :order_bid do
    create :order_bid, \
       bid:           :usd,
       ask:           :btc,
       market:        Market.find_spot_by_symbol(:btcusd),
       state:         :wait,
       ord_type:      :limit,
       price:         '1.2'.to_d,
       volume:        '10000',
       origin_volume: '10000',
       locked:        '12000',
       origin_locked: '12000',
       member:        buyer
  end

  let(:deposit_btc) { create(:deposit_btc, member: seller, amount: order_ask.locked, currency_id: :btc) }

  let(:deposit_usd) { create(:deposit_usd, member: buyer, amount: order_bid.locked, currency_id: :usd) }

  let :executor do
    ask = Matching::LimitOrder.new(order_ask.to_matching_attributes)
    bid = Matching::LimitOrder.new(order_bid.to_matching_attributes)
    Matching::Executor.new \
      action: 'execute',
      trade: {
        market_id:       :btcusd,
        maker_order_id:  ask.id,
        taker_order_id:  bid.id,
        strike_price:    '1.2',
        amount:          '10000',
        total:           '12000'
      }
  end

  let(:asset_balance) { Operations::Asset.balance }
  let(:liability_balance) { Operations::Liability.balance }
  let(:revenue_balance) { Operations::Revenue.balance }
  let(:expense_balance) { Operations::Expense.balance }
  let!(:tx) { Transaction.create(txid: deposit_btc.txid, reference: deposit_btc, kind: 'tx', from_address: 'fake_address', to_address: deposit_btc.address, blockchain_key: deposit_btc.blockchain_key, status: :pending, currency_id: deposit_btc.currency_id) }

  before do
    deposit_btc.accept!
    deposit_btc.process!
    deposit_btc.dispatch!
    deposit_usd.accept!

    order_bid.hold_account!.lock_funds!(order_bid.locked)
    order_bid.record_submit_operations!

    order_ask.hold_account!.lock_funds!(order_ask.locked)
    order_ask.record_submit_operations!

    executor.execute!
  end

  it 'assert that asset - liabilities = revenue - expense' do
    expect(asset_balance.merge(liability_balance){ |k, a, b| a - b}).to eq (revenue_balance.merge(expense_balance){ |k, a, b| a - b})
  end

  it 'assert the balance is 15.0 / 18.0 $' do
    balance = asset_balance.merge(liability_balance){ |k, a, b| a - b}

    expect(balance.fetch(:btc)).to eq '15.0'.to_d
    expect(balance.fetch(:usd)).to eq '18.0'.to_d
  end

  context 'withdraws' do
    before do
      BlockchainCurrency.find_by(currency_id: 'btc').update(auto_update_fees_enabled: false, withdraw_fee: 0.01)
    end

    let(:btc_withdraw) { create(:btc_withdraw, sum: 1000.to_d, member: buyer ) }
    let!(:withdraw_tx) { Transaction.create(txid: btc_withdraw.txid, reference: btc_withdraw, kind: 'tx', from_address: 'fake_address', to_address: btc_withdraw.rid, blockchain_key: btc_withdraw.blockchain_key, status: :pending, currency_id: btc_withdraw.currency_id) }

    before do
      btc_withdraw.accept!
      btc_withdraw.update(txid: 'a1a43ab7166f81059449f80a35abdc6febe62fe1f75a0cdb25d49ebae3fc10d9')
      btc_withdraw.process!
      btc_withdraw.dispatch!
      btc_withdraw.success!
    end

    it 'after btc withdraw, assert that asset - liabilities = revenue - expense' do
      expect(asset_balance.merge(liability_balance){ |k, a, b| a - b}).to eq (revenue_balance.merge(expense_balance){ |k, a, b| a - b})
    end

    it 'after btc withdraw (fee: 0.01) assert the balance is 15.01 / 18.0 $' do
      balance = asset_balance.merge(liability_balance){ |k, a, b| a - b}

      expect(balance.fetch(:btc)).to eq '15.01'.to_d
      expect(balance.fetch(:usd)).to eq '18.0'.to_d
    end
  end
end
