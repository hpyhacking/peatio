# encoding: UTF-8
# frozen_string_literal: true

describe Trade, '.latest_price' do
  context 'no trade' do
    it { expect(Trade.latest_price(:btcusd)).to be_d '0.0' }
  end

  context 'add one trade' do
    let!(:trade) { create(:trade, :btcusd, market_id: :btcusd) }
    it { expect(Trade.latest_price(:btcusd)).to eq(trade.price) }
  end
end

describe Trade, '#for_notify' do
  let(:order_ask) { create(:order_ask, :btcusd) }
  let(:order_bid) { create(:order_bid, :btcusd) }
  let(:trade) { create(:trade, :btcusd, maker_order: order_ask, taker_order: order_bid) }

  subject(:notify) { trade.for_notify(order_ask.member) }

  it { expect(notify).not_to be_blank }
  it { expect(notify[:side]).not_to be_blank }
  it { expect(notify[:created_at]).not_to be_blank }
  it { expect(notify[:price]).not_to be_blank }
  it { expect(notify[:amount]).not_to be_blank }
  it { expect(notify[:order_id]).to eq(order_ask.id) }

  it 'should use side as kind' do
    expect(trade.for_notify(Member.find(trade.maker_id))[:side]).to eq 'sell'
  end

  context 'notify for bid member' do
    subject(:notify) { trade.for_notify(order_bid.member) }

    it { expect(notify).not_to be_blank }
    it { expect(notify[:side]).not_to be_blank }
    it { expect(notify[:created_at]).not_to be_blank }
    it { expect(notify[:price]).not_to be_blank }
    it { expect(notify[:amount]).not_to be_blank }
    it { expect(notify[:order_id]).to eq(order_bid.id) }
  end
end

describe Trade, '#market_ticker_from_influx' do
  after { delete_measurments("trades") }

  context 'no trades executed yet' do
    it 'returns ticker' do
      expect(Trade.market_ticker_from_influx(:btcusd)).to eq([])
    end
  end

  context 'single trade was executed' do
    let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
    let(:expected_ticker) do
      {
        :min=>5,
        :max=>5,
        :first=>5,
        :last=>5,
        :volume=>5.5,
        :amount=>1.1,
        :vwap=>5
      }
    end

    before do
      trade.write_to_influx
    end

    it 'returns ticker' do
      expect(Trade.market_ticker_from_influx(trade.market_id).except(:time)).to eq(expected_ticker)
    end
  end

  context 'multiple trades were executed' do
    let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
    let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}
    let!(:trade3) { create(:trade, :btcusd, price: '7.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}
    let(:expected_ticker) do
      {
        :amount => 2.9,
        :first => 5,
        :last => 7,
        :max => 7,
        :min => 5,
        :volume => 16.3,
        :vwap => 5.620689655172415
      }
    end

    before do
      trade1.write_to_influx
      trade2.write_to_influx
      trade3.write_to_influx
    end

    it 'returns ticker' do
      expect(Trade.market_ticker_from_influx(trade1.market_id).except(:time)).to eq(expected_ticker)
    end
  end
end

describe Trade, '#record_complete_operations!' do
  # Persist orders and trades in database.
  let!(:trade){ create(:trade, :btcusd, :with_deposit_liability) }

  let(:ask){ trade.maker_order }
  let(:bid){ trade.taker_order }

  let(:ask_currency_outcome){ trade.amount }
  let(:bid_currency_outcome){ trade.total }

  let(:ask_currency_fee){ trade.amount * trade.order_fee(bid) }
  let(:bid_currency_fee){ trade.total * trade.order_fee(ask) }

  let(:ask_currency_income){ ask_currency_outcome - ask_currency_fee }
  let(:bid_currency_income){ bid_currency_outcome - bid_currency_fee }

  subject{ trade }

  it 'creates four liability operations' do
    expect{ subject.record_complete_operations! }.to change{ Operations::Liability.count }.by(4)
  end

  it 'doesn\'t create asset operations' do
    expect{ subject.record_complete_operations! }.to_not change{ Operations::Asset.count }
  end

  it 'debits locked ask liabilities for ask creator' do
    expect{ subject.record_complete_operations! }.to change {
      ask.member.balance_for(currency: ask.currency, kind: :locked)
    }.by(-ask_currency_outcome)
  end

  it 'debits locked bid liabilities for bid creator' do
    expect{ subject.record_complete_operations! }.to change {
      bid.member.balance_for(currency: bid.currency, kind: :locked)
    }.by(-bid_currency_outcome)
  end

  it 'credits main bid liabilities for ask creator' do
    expect{ subject.record_complete_operations! }.to change {
      ask.member.balance_for(currency: bid.currency, kind: :main)
    }.by(bid_currency_income)
  end

  it 'credits main ask liabilities for bid creator' do
    expect{ subject.record_complete_operations! }.to change {
      bid.member.balance_for(currency: ask.currency, kind: :main)
    }.by(ask_currency_income)
  end

  it 'credits ask currency revenues' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.balance(currency: ask.currency)
    }.by(ask_currency_fee)
  end

  it 'credits bid currency revenues' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.balance(currency: bid.currency)
    }.by(bid_currency_fee)
  end

  it 'creates ask currency revenue from bid creator' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.where(currency: ask.currency, member: bid.member).count
    }.by(1)
  end

  it 'creates bid currency revenue from ask creator' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.where(currency: bid.currency, member: ask.member).count
    }.by(1)
  end
end
