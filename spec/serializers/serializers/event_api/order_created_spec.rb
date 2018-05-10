describe Serializers::EventAPI::OrderCreated do
  let(:buyer) { create(:member, :verified_identity, :barong) }

  let :order_bid do
    # Buy 14 BTC for 0.42 USD (0.03 USD per BTC).
    create :order_bid, \
      bid:           Currency.find_by!(code: :usd).id,
      ask:           Currency.find_by!(code: :btc).id,
      market:        Market.find(:btcusd),
      state:         :wait,
      source:        'Web',
      ord_type:      :limit,
      price:         '0.03'.to_d,
      volume:        '14.0',
      origin_volume: '14.0',
      locked:        '0.42',
      origin_locked: '0.42',
      member:        buyer
  end  

  subject { order_bid }

  let(:created_at) { Time.current }

  before do
    buyer.ac(:btc).plus_funds('100.0'.to_d)
    buyer.ac(:btc).lock_funds('100.0'.to_d)
  end

  before { OrderBid.any_instance.expects(:created_at).returns(created_at).at_least_once }

  before do
    EventAPI.expects(:notify).with('market.btcusd.order_created', {
      market:                 'btcusd',
      type:                   'buy',
      trader_uid:             buyer.uid,
      income_unit:            'btc',
      income_fee_type:        'relative',
      income_fee_value:       '0.0015',
      outcome_unit:           'usd',
      outcome_fee_type:       'relative',
      outcome_fee_value:      '0.0',
      initial_income_amount:  '14.0',
      current_income_amount:  '14.0',
      initial_outcome_amount: '0.42',
      current_outcome_amount: '0.42',
      strategy:               'limit',
      price:                  '0.03',
      state:                  'open',
      trades_count:           0,
      created_at:             created_at.iso8601
    }).once
  end

  it('publishes event') { subject }
end
