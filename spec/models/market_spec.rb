# encoding: UTF-8
# frozen_string_literal: true

describe Market do
  context 'market attributes' do
    subject { Market.find(:btcusd) }

    it 'id' do
      expect(subject.id).to eq 'btcusd'
    end

    it 'name' do
      expect(subject.name).to eq 'BTC/USD'
    end

    it 'base_currency' do
      expect(subject.base_unit).to eq 'btc'
      expect(subject.base_currency).to eq 'btc'
    end

    it 'quote_currency' do
      expect(subject.quote_unit).to eq 'usd'
      expect(subject.quote_currency).to eq 'usd'
    end

    it 'state' do
      expect(subject.state).to eq 'enabled'
    end

    it 'data' do
      expect(subject.data).to eq({})
    end
  end

  context 'validations' do
    let(:valid_attributes) do
      { base_currency:    :btc,
        quote_currency:   :trst,
        engine:           create(:engine),
        min_amount:       0.0001,
        min_price:        0.0001,
        amount_precision: 4,
        price_precision:  4,
        position:         100 }
    end

    let(:mirror_attributes) do
      { base_currency:    :usd,
        quote_currency:   :btc,
        engine:           create(:engine),
        min_amount:       0.0001,
        min_price:        0.0001,
        amount_precision: 4,
        price_precision:  4,
        position:         100 }
    end

    let(:disabled_currency) { Currency.find_by_id(:eur) }

    it 'creates valid record' do
      record = Market.new(valid_attributes)

      expect(record.save).to eq true
    end

    it 'validates quote currency duplication' do
      record = Market.new(valid_attributes.merge(quote_currency: valid_attributes[:base_currency]))
      record.save
      expect(record.errors.full_messages).to include(/quote currency duplicates base currency/i)
    end

    it 'validates same market' do
      record = build(:market, :btcusd)
      record.save
      expect(record.errors.full_messages).to include(/market already exists/i)
    end

    it 'validates mirror market pair' do
      record = Market.new(mirror_attributes)
      record.save
      expect(record.errors.full_messages).to include(/market already exists/i)
    end

    it 'validates presence of currencies' do
      %i[base_currency quote_currency].each do |field|
        record = Market.new(valid_attributes.except(field))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} can't be blank/i)
      end
    end

    it 'validates fields to be greater than or equal to 0' do
      %i[price_precision amount_precision].each do |field|
        record = Market.new(valid_attributes.merge(field => -1))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} must be greater than or equal to 0/i)
      end
    end

    it 'validates fields to be greater than or equal to top position' do
      record = Market.new(valid_attributes.merge(:position => 0))
      record.save
      expect(record.errors.full_messages).to include(/position must be greater than or equal to 1/i)
    end

    it 'validates fields to be greater than or equal to 0' do
      %i[price_precision amount_precision].each do |field|
        record = Market.new(valid_attributes.merge(field => 'test'))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} is not a number/i)
      end
    end

    it 'validates fields to be integer' do
      %i[price_precision amount_precision position].each do |field|
        record = Market.new(valid_attributes.merge(field => 0.1))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} must be an integer/i)
      end
    end

    it 'validates currencies codes to be inclusion of currency codes' do
      %i[base_currency quote_currency].each do |field|
        record = Market.new(valid_attributes.merge(field => :bad))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} is not included in the list/i)
      end
    end

    it 'validate position value on update' do
      market = Market.find(:btcusd)
      market.update(position: nil)
      expect(market.valid?).to eq false
      expect(market.errors[:position].size).to eq(2)

      market.update(position: 0)
      expect(market.valid?).to eq false
      expect(market.errors[:position].size).to eq(1)
    end

    it 'allows to disable all markets' do
      Market.where.not(id: :btcusd).update_all(state: :disabled)
      market = Market.find(:btcusd)
      market.update(state: :disabled)
      market.valid?
      expect(market.errors[:market].size).to eq(0)
    end

    it 'validates min_amount from amount_precision variable' do
      record = Market.new(valid_attributes)
      expect(record.save).to eq true

      # Delete record since amount_precision is readonly attribute.
      record.delete

      record = Market.new(valid_attributes.merge(amount_precision: 2))
      expect(record.save).to eq false
      expect(record.errors.full_messages).to include(/#{to_readable(:min_amount)} must be greater than or equal to 0.01/i)
    end

    it 'allows to set min_amount greater than value defined by amount_precision' do
      record = Market.new(valid_attributes.merge(min_amount: 1))
      expect(record.save).to eq true
    end

    def to_readable(field)
      field.to_s.humanize.downcase
    end
  end

  context 'relationships' do
    subject { Market.find(:btcusd) }
    before do
      create(:trading_fee, market_id: :btcusd)
      create(:trading_fee, market_id: :btceth)
      create(:trading_fee)
    end

    it 'deletes only btcusd trading_fee' do
      expect { subject.destroy! }.to change(TradingFee, :count).by(-1)
    end
  end

  context 'validate max market' do
    before { ENV['MAX_MARKETS'] = '2' }
    after  { ENV['MAX_MARKETS'] = nil }

    it 'should raise validation error for max market' do
      record = build(:market, :btctrst)
      record.save
      expect(record.errors.full_messages).to include(/Max Market limit has been reached/i)
    end
  end

  context 'callbacks' do
    let(:valid_attributes) do
      { base_currency:    :btc,
        quote_currency:   :trst,
        engine:           create(:engine),
        min_amount:       0.0001,
        min_price:        0.0001,
        amount_precision: 4,
        price_precision:  4
      }
    end

    context 'after_create' do

      it 'move to the bottom if there is no position' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2]]
        Market.create(valid_attributes)
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
      end

      it 'move to the bottom of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2]]
        Market.create(valid_attributes.merge(position: 3))
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
      end

      it 'move to the bottom when position is greater that currencies count' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2]]
        Market.create(valid_attributes.merge(position: Market.all.count + 2))
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
      end

      it 'move to the top of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2]]
        Market.create(valid_attributes.merge(position: 1))
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btctrst", 1], ["btcusd", 2], ["btceth", 3]]
      end

      it 'move to the middle of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2]]
        Market.create(valid_attributes.merge(position: 2))
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btctrst", 2], ["btceth", 3]]
      end
    end

    context 'before update' do
      let!(:btctrst) { Market.create(valid_attributes) }
      let(:btceth) { Market.find(:btceth) }

      it 'move to the bottom of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
        btceth.update(position: 3)
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btctrst", 2], ["btceth", 3]]
      end

      it 'move to the bottom when position is greater that markets count' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
        btceth.update(position: Market.all.count + 2)
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btctrst", 2], ["btceth", 3]]
      end

      it 'move to the top of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
        btceth.update(position: 1)
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btceth", 1], ["btcusd", 2], ["btctrst", 3]]
      end

      it 'move to the middle of all currencies' do
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btceth", 2], ["btctrst", 3]]
        btctrst.update(position: 2)
        expect(Market.all.ordered.pluck(:id, :position)).to eq [["btcusd", 1], ["btctrst", 2], ["btceth", 3]]
      end
    end
  end
end
