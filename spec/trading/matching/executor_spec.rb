# encoding: UTF-8
# frozen_string_literal: true

describe Matching::Executor do
  let(:alice)  { who_is_billionaire }
  let(:bob)    { who_is_billionaire }
  let(:market) { Market.find('btcusd') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }

  subject do
    Matching::Executor.new(
      market_id:    market.id,
      ask_id:       ask.id,
      bid_id:       bid.id,
      strike_price: price.to_s('F'),
      volume:       volume.to_s('F'),
      funds:        (price * volume).to_s('F')
    )
  end

  context 'invalid volume' do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: 3.to_d, member: bob).to_matching_attributes }

    it 'should raise error' do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context 'invalid price' do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price - 1, volume: volume, member: bob).to_matching_attributes }

    it 'should raise error' do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context 'full execution' do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: volume, member: bob).to_matching_attributes }

    it 'should create trade' do
      expect do
        trade = subject.execute!

        expect(trade.trend).to eq 'up'
        expect(trade.price).to eq price
        expect(trade.volume).to eq volume
        expect(trade.ask_id).to eq ask.id
        expect(trade.bid_id).to eq bid.id
      end.to change(Trade, :count).by(1)
    end

    it 'should set trend to down' do
      Market.any_instance.expects(:latest_price).returns(11.to_d)
      trade = subject.execute!
      expect(trade.trend).to eq 'down'
    end

    it 'should set trade used funds' do
      Market.any_instance.expects(:latest_price).returns(11.to_d)
      trade = subject.execute!
      expect(trade.funds).to eq price * volume
    end

    it 'should increase order\'s trades count' do
      subject.execute!
      expect(Order.find(ask.id).trades_count).to eq 1
      expect(Order.find(bid.id).trades_count).to eq 1
    end

    it 'should mark both orders as done' do
      subject.execute!
      expect(Order.find(ask.id).state).to eq Order::DONE
      expect(Order.find(bid.id).state).to eq Order::DONE
    end

    it 'should publish trade through amqp' do
      AMQPQueue.expects(:publish)
      subject.execute!
    end
  end

  context 'partial ask execution' do
    let(:ask) { create(:order_ask, price: price, volume: 7.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: 5.to_d, member: bob) }

    it 'should set bid to done only' do
      subject.execute!

      expect(ask.reload.state).not_to eq Order::DONE
      expect(bid.reload.state).to eq Order::DONE
    end
  end

  context 'partial bid execution' do
    let(:ask) { create(:order_ask, price: price, volume: 5.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: 7.to_d, member: bob) }

    it 'should set ask to done only' do
      subject.execute!

      expect(ask.reload.state).to eq Order::DONE
      expect(bid.reload.state).not_to eq Order::DONE
    end
  end

  context 'partially filled market order whose locked fund run out' do
    let(:ask) { create(:order_ask, price: '2.0'.to_d, volume: '3.0'.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: nil, ord_type: 'market', volume: '2.0'.to_d, locked: '3.0'.to_d, member: bob) }

    it 'should cancel the market order' do
      executor = Matching::Executor.new(
        market_id:    market.id,
        ask_id:       ask.id,
        bid_id:       bid.id,
        strike_price: '2.0'.to_d,
        volume:       '1.5'.to_d,
        funds:        '3.0'.to_d
      )
      executor.execute!

      expect(bid.reload.state).to eq Order::CANCEL
    end
  end

  context 'unlock not used funds' do
    let(:ask) { create(:order_ask, price: price - 1, volume: 7.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: volume, member: bob) }

    subject do
      Matching::Executor.new(
        market_id:    market.id,
        ask_id:       ask.id,
        bid_id:       bid.id,
        strike_price: price - 1, # so bid order only used (price-1)*volume
        volume:       volume.to_s('F'),
        funds:        ((price - 1) * volume).to_s('F')
      )
    end

    it 'should unlock funds not used by bid order' do
      locked_before = bid.hold_account.reload.locked

      subject.execute!
      locked_after = bid.hold_account.reload.locked

      expect(locked_after).to eq locked_before - (price * volume)
    end

    it 'should save unused amount in order locked attribute' do
      subject.execute!
      expect(bid.reload.locked).to eq price * volume - (price - 1) * volume
    end
  end

  context 'execution fail' do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: volume, member: bob).to_matching_attributes }

    it 'should not create trade' do
      # set locked funds to 0 so strike will fail
      alice.get_account(:btc).update_attributes(locked: ::Trade::ZERO)

      expect do
        expect { subject.execute! }.to raise_error(Account::AccountError)
      end.not_to change(Trade, :count)
    end
  end
end
