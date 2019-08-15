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
  end

  # TODO: Find better way for delegation testing.
  context 'shortcut of global access' do
    let(:market) { Market.find(:btcusd) }

    it 'bids' do
      expect(market.bids).to eq market.global.bids
    end

    it 'asks' do
      expect(market.asks).to eq market.global.asks
    end

    it 'trades' do
      expect(market.trades).to eq market.global.trades
    end

    it 'ticker' do
      expect(market.ticker).to eq market.global.ticker
    end

    it 'h24_volume' do
      expect(market.h24_volume).to eq market.global.h24_volume
    end

    it 'avg_h24_price' do
      expect(market.avg_h24_price).to eq market.global.avg_h24_price
    end
  end

  context 'validations' do
    let(:valid_attributes) do
      { base_currency:    :btc,
        quote_currency:   :trst,
        taker_fee:        0.1,
        maker_fee:        0.2,
        min_amount:       0.0001,
        min_price:        0.0001,
        amount_precision: 4,
        price_precision:  4,
        position:         100 }
    end

    let(:mirror_attributes) do
      { base_currency:    :usd,
        quote_currency:   :btc,
        maker_fee:        0.1,
        taker_fee:        0.2,
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
      %i[maker_fee taker_fee price_precision amount_precision position].each do |field|
        record = Market.new(valid_attributes.merge(field => -1))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} must be greater than or equal to 0/i)
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

    it 'validates if both currencies enabled on enabled market creation' do
      %i[base_currency quote_currency].each do |field|
        record = Market.new(valid_attributes.merge(field => disabled_currency.code))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} is not enabled/i)
      end
    end

    it 'doesn\'t validate if both currencies enabled on disabled market creation' do
      %i[base_currency quote_currency].each do |field|
        record = Market.new(valid_attributes.merge(field => disabled_currency.code, state: 'disabled'))
        expect(record.save).to eq true
      end
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

    it 'validates fee preciseness' do
      record = Market.create(valid_attributes)

      %i[maker_fee taker_fee].each do |f|
        record.reload
        expect(record.update(f => 0.0001)).to eq true
        expect(record.update(f => 0.00011)).to eq false
        expect(record.update(f => 0.00001)).to eq false
        expect(record.update(f => 0.02000003)).to eq false
      end
    end

    it 'allows to set min_amount greater than value defined by amount_precision' do
      record = Market.new(valid_attributes.merge(min_amount: 1))
      expect(record.save).to eq true
    end

    def to_readable(field)
      field.to_s.humanize.downcase
    end
  end
end
