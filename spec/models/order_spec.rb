# encoding: UTF-8
# frozen_string_literal: true

describe Order, 'validations', type: :model do
  context 'validations' do
    subject do
      Order.validators
           .select { |v| v.is_a? ActiveRecord::Validations::PresenceValidator }
           .map(&:attributes)
           .flatten
    end

    it do
      is_expected.to include :ord_type
      is_expected.to include :volume
      is_expected.to include :origin_volume
      is_expected.to include :locked
      is_expected.to include :origin_locked
    end
  end

  context 'limit order' do
    it 'should make sure price is present' do
      order = OrderAsk.new(market_id: 'btcusd', price: nil, ord_type: 'limit')
      expect(order).not_to be_valid
      expect(order.errors[:price]).to include 'is not a number'
    end
  end

  context 'market order' do
    it 'should make sure price is not present' do
      order = OrderAsk.new(market_id: 'btcusd', price: '0.0'.to_d, ord_type: 'market')
      expect(order).not_to be_valid
      expect(order.errors[:price]).to include 'must not be present'
    end
  end

  context 'attr_readonly' do
    let!(:order) { create(:order_bid, :btcusd) }

    it "does not allow updating readonly attributes" do
      expect { order.update_attribute(:member_id, 1) }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'member_id is marked as readonly')

      expect { order.update_attribute(:bid, 'xyz') }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'bid is marked as readonly')

      expect { order.update_attribute(:ask, 'abc') }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'ask is marked as readonly')

      expect { order.update_attribute(:market_id, 'abcxyz') }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'market_id is marked as readonly')

      expect { order.update_attribute(:ord_type, 'market') }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'ord_type is marked as readonly')

      expect { order.update_attribute(:origin_volume, 1) }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'origin_volume is marked as readonly')

      expect { order.update_attribute(:origin_locked, 1) }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'origin_locked is marked as readonly')

      expect { order.update_attribute(:created_at, '2009-01-03') }.to \
        raise_error(ActiveRecord::ActiveRecordError, 'created_at is marked as readonly')
    end
  end
end

describe Order, '#submit' do
  let(:order) { create(:order_bid, :with_deposit_liability, state: 'pending', price: '12.32'.to_d, volume: '123.12345678') }
  let(:rejected_order) { create(:order_bid, :with_deposit_liability, state: 'reject', price: '12.32'.to_d, volume: '123.12345678') }
  let(:order_bid) { create(:order_bid, :with_deposit_liability, state: 'pending', price: '12.32'.to_d, volume: '123.12345678') }
  let(:order_ask) { create(:order_ask, :with_deposit_liability, state: 'pending', price: '12.32'.to_d, volume: '123.12345678') }

  before do
    Order.submit(order_bid.id)
    Order.submit(order_ask.id)
  end

  it do
    expect(order_bid.reload.state).to eq 'wait'
    expect(Operations::Liability.where(reference: order_ask).count).to eq 2
    expect(Operations::Liability.where(reference: order_bid).count).to eq 2
  end

  context 'validations' do
    before do
      order.member.accounts.find_by_currency_id(order.currency).update(balance: 0)
    end

    it 'insufficient balance' do
      expect {
        Order.submit(order.id)
      }.to raise_error(Account::AccountError)
      expect(order.reload.state).to eq('reject')
    end

    it 'rejected order' do
      Order.submit(rejected_order.id)
      expect(rejected_order.reload.state).to eq('reject')
    end
  end

  it 'mysql connection error' do
    ActiveRecord::Base.stubs(:transaction).raises(Mysql2::Error::ConnectionError.new(''))
    expect { Order.submit(order.id) }.to raise_error(Mysql2::Error::ConnectionError)
  end
end

describe Order, '#cancel' do
  let(:order) { create(:order_bid, :with_deposit_liability, state: 'pending', price: '12.32'.to_d, volume: '123.12345678') }

  it 'mysql connection error' do
    ActiveRecord::Base.stubs(:transaction).raises(Mysql2::Error::ConnectionError.new(''))
    expect { Order.cancel(order.id) }.to raise_error(Mysql2::Error::ConnectionError)
  end
end

describe Order, 'precision validations', type: :model do
  let(:order_bid) { build(:order_bid, :btcusd, price: '12.32'.to_d, volume: '123.123456789') }
  let(:order_ask) { build(:order_ask, :btcusd, price: '12.326'.to_d, volume: '123.12345678') }

  it 'validates origin_volume precision' do
    record = order_bid
    expect(record.save).to eq false
    expect(record.errors[:origin_volume]).to include(/precision must be less than or equal to 8/i)
  end

  it 'validates price precision' do
    record = order_ask
    expect(record.save).to eq false
    expect(record.errors[:price]).to include(/precision must be less than or equal to 2/i)
  end
end

describe Order, '#done', type: :model do
  let(:ask_fee) { '0.003'.to_d }
  let(:bid_fee) { '0.001'.to_d }
  let(:order) { order_bid }
  let(:order_bid) { create(:order_bid, :btcusd, price: '1.2'.to_d, volume: '10.0'.to_d) }
  let(:order_ask) { create(:order_ask, :btcusd, price: '1.2'.to_d, volume: '10.0'.to_d) }
  let(:hold_account) { create_account(:usd, locked: '100.0'.to_d) }
  let(:expect_account) { create_account(:btc) }

  before do
    order_bid.stubs(:hold_account!).returns(hold_account.lock!)
    order_bid.stubs(:expect_account!).returns(expect_account.lock!)
    order_ask.stubs(:hold_account!).returns(hold_account.lock!)
    order_ask.stubs(:expect_account!).returns(expect_account.lock!)
    OrderBid.any_instance.stubs(:fee).returns(bid_fee)
    OrderAsk.any_instance.stubs(:fee).returns(ask_fee)
  end

  def mock_trade(volume, price)
    build(:trade, volume: volume, price: price, id: rand(10))
  end

  shared_examples 'trade done' do
    before do
      hold_account.reload
      expect_account.reload
    end
  end
end

describe Order, '#kind' do
  it 'should be ask for ask order' do
    expect(OrderAsk.new.kind).to eq 'ask'
  end

  it 'should be bid for bid order' do
    expect(OrderBid.new.kind).to eq 'bid'
  end
end

describe Order, 'related accounts' do
  let(:alice) { who_is_billionaire }
  let(:bob)   { who_is_billionaire }

  context OrderAsk do
    it 'should hold btc and expect usd' do
      ask = create(:order_ask, :btcusd, member: alice)
      expect(ask.hold_account).to eq alice.get_account(:btc)
      expect(ask.expect_account).to eq alice.get_account(:usd)
    end
  end

  context OrderBid do
    it 'should hold usd and expect btc' do
      bid = create(:order_bid, :btcusd, member: bob)
      expect(bid.hold_account).to eq bob.get_account(:usd)
      expect(bid.expect_account).to eq bob.get_account(:btc)
    end
  end
end

describe Order, '#avg_price' do
  it 'should be zero if not filled yet' do
    expect(
      OrderAsk.new(
        locked: '1.0',
        origin_locked: '1.0',
        volume: '1.0',
        origin_volume: '1.0',
        funds_received: '0'
      ).avg_price
    ).to eq '0'.to_d

    expect(
      OrderBid.new(
        locked: '1.0',
        origin_locked: '1.0',
        volume: '1.0',
        origin_volume: '1.0',
        funds_received: '0'
      ).avg_price
    ).to eq '0'.to_d
  end

  it 'should calculate average price of bid order' do
    expect(
      OrderBid.new(
        market_id: 'btcusd',
        locked: '10.0',
        origin_locked: '20.0',
        volume: '1.0',
        origin_volume: '3.0',
        funds_received: '2.0'
      ).avg_price
    ).to eq '5'.to_d
  end

  it 'should calculate average price of ask order' do
    expect(
      OrderAsk.new(
        market_id: 'btcusd',
        locked: '1.0',
        origin_locked: '2.0',
        volume: '1.0',
        origin_volume: '2.0',
        funds_received: '10.0'
      ).avg_price
    ).to eq '10'.to_d
  end
end

describe Order, '#record_submit_operations!' do
  # Persist Order in database.
  let!(:order){ create(:order_ask, :btcusd, :with_deposit_liability) }

  subject { order }

  it 'creates two liability operations' do
    expect{ subject.record_submit_operations! }.to change{ Operations::Liability.count }.by(2)
  end

  it 'doesn\'t create asset operations' do
    expect{ subject.record_submit_operations! }.to_not change{ Operations::Asset.count }
  end

  it 'debits main liabilities for member' do
    expect{ subject.record_submit_operations! }.to change {
      subject.member.balance_for(currency: subject.currency, kind: :main)
    }.by(-subject.locked)
  end

  it 'credits locked liabilities for member' do
    expect{ subject.record_submit_operations! }.to change {
      subject.member.balance_for(currency: subject.currency, kind: :locked)
    }.by(subject.locked)
  end
end

describe Order, '#record_cancel_operations!' do
  # Persist Order in database.
  let!(:order){ create(:order_ask, :with_deposit_liability) }

  subject { order }
  before { subject.record_submit_operations! }

  it 'creates two liability operations' do
    expect{ subject.record_cancel_operations! }.to change{ Operations::Liability.count }.by(2)
  end

  it 'doesn\'t create asset operations' do
    expect{ subject.record_cancel_operations! }.to_not change{ Operations::Asset.count }
  end

  it 'credits main liabilities for member' do
    expect{ subject.record_cancel_operations! }.to change {
      subject.member.balance_for(currency: subject.currency, kind: :main)
    }.by(subject.locked)
  end

  it 'debits locked liabilities for member' do
    expect{ subject.record_cancel_operations! }.to change {
      subject.member.balance_for(currency: subject.currency, kind: :locked)
    }.by(-subject.locked)
  end
end

describe Order, '#trigger_event' do

  context 'trigger pusher event for limit order' do
    let!(:order){ create(:order_ask, :with_deposit_liability) }

    subject { order }

    let(:data) do
      {
        id:               subject.id,
        market:           subject.market_id,
        kind:             subject.kind,
        side:             subject.side,
        ord_type:         subject.ord_type,
        price:            subject.price&.to_s('F'),
        avg_price:        subject.avg_price&.to_s('F'),
        state:            subject.state,
        origin_volume:    subject.origin_volume.to_s('F'),
        remaining_volume: subject.volume.to_s('F'),
        executed_volume:  (subject.origin_volume - subject.volume).to_s('F'),
        at:               subject.created_at.to_i,
        created_at:       subject.created_at.to_i,
        updated_at:       subject.updated_at.to_i,
        trades_count:     subject.trades_count,
      }
    end

    before { ::AMQP::Queue.expects(:enqueue_event).with('private', subject.member.uid, 'order', data) }

    it { subject.trigger_event }
  end

  context 'trigger pusher event for market order' do
    let!(:order) { create(:order_ask, :with_deposit_liability, ord_type: 'market', price: nil) }

    subject { order }

    let(:data) do
      {
        id:               subject.id,
        market:           subject.market_id,
        kind:             subject.kind,
        side:             subject.side,
        ord_type:         subject.ord_type,
        price:            subject.price&.to_s('F'),
        avg_price:        subject.avg_price&.to_s('F'),
        state:            subject.state,
        origin_volume:    subject.origin_volume.to_s('F'),
        remaining_volume: subject.volume.to_s('F'),
        executed_volume:  (subject.origin_volume - subject.volume).to_s('F'),
        at:               subject.created_at.to_i,
        created_at:       subject.created_at.to_i,
        updated_at:       subject.updated_at.to_i,
        trades_count:     subject.trades_count
      }
    end

    it 'doesnt push event for active market order' do
      ::AMQP::Queue.expects(:enqueue_event).with(:order, data).never
      subject.trigger_event
    end

    it 'pushes event for completed market order' do
      subject.expects(:trigger_event)
      subject.update!(state: 'done')
    end

    context do
      it do
        subject.update!(state: 'done')
        ::AMQP::Queue.expects(:enqueue_event).with('private', subject.member.uid, 'order', data)
        subject.trigger_event
      end
    end
  end
end
