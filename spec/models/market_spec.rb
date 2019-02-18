# encoding: UTF-8
# frozen_string_literal: true

describe Market do
  context 'enabled market' do
    it { expect(Market.enabled.count).to eq(4) }
  end

  context 'market attributes' do
    subject { Market.find(:btcusd) }

    it 'id' do
      expect(subject.id).to eq 'btcusd'
    end

    it 'name' do
      expect(subject.name).to eq 'BTC/USD'
    end

    it 'base_unit' do
      expect(subject.base_unit).to eq 'btc'
    end

    it 'quote_unit' do
      expect(subject.quote_unit).to eq 'usd'
    end

    it 'enabled' do
      expect(subject.enabled).to be true
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
      { ask_unit:      :btc,
        bid_unit:      :trst,
        bid_fee:       0.1,
        ask_fee:       0.2,
        ask_precision: 4,
        bid_precision: 4,
        position:      100 }
    end

    let(:mirror_attributes) do
      { ask_unit:      :usd,
        bid_unit:      :btc,
        bid_fee:       0.1,
        ask_fee:       0.2,
        ask_precision: 4,
        bid_precision: 4,
        position:      100 }
    end

    let(:disabled_currency) { Currency.find_by_id(:eur) }

    it 'creates valid record' do
      record = Market.new(valid_attributes)
      expect(record.save).to eq true
    end

    it 'validates equivalence of units' do
      record = Market.new(valid_attributes.merge(bid_unit: valid_attributes[:ask_unit]))
      record.save
      expect(record.errors.full_messages).to include(/ask unit is invalid/i)
    end

    it 'validates uniqueness of ID' do
      record = build(:market, :btcusd)
      record.save
      expect(record.errors.full_messages).to include(/id has already been taken/i)
    end

    it 'validates mirror market pair' do
      record = Market.new(mirror_attributes)
      record.save
      expect(record.errors.full_messages).to include(/id has already been taken/i)
    end

    it 'validates presence of units' do
      %i[bid_unit ask_unit].each do |field|
        record = Market.new(valid_attributes.except(field))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} can't be blank/i)
      end
    end

    it 'validates fields to be greater than or equal to 0' do
      %i[bid_fee ask_fee bid_precision ask_precision position].each do |field|
        record = Market.new(valid_attributes.merge(field => -1))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} must be greater than or equal to 0/i)
      end
    end

    it 'validates fields to be integer' do
      %i[bid_precision ask_precision position].each do |field|
        record = Market.new(valid_attributes.merge(field => 0.1))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} must be an integer/i)
      end
    end

    it 'validates unit codes to be inclusion of currency codes' do
      %i[bid_unit ask_unit].each do |field|
        record = Market.new(valid_attributes.merge(field => :bad))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} is not included in the list/i)
      end
    end

    it 'validates if both currencies enabled on enabled market creation' do
      %i[bid_unit ask_unit].each do |field|
        record = Market.new(valid_attributes.merge(field => disabled_currency.code))
        record.save
        expect(record.errors.full_messages).to include(/#{to_readable(field)} is not enabled/i)
      end
    end

    it 'doesn\'t validate if both currencies enabled on disabled market creation' do
      %i[bid_unit ask_unit].each do |field|
        record = Market.new(valid_attributes.merge(field => disabled_currency.code, enabled: false))
        expect(record.save).to eq true
      end
    end

    it 'doesn\'t allow to disable all markets' do
      Market.where.not(id: :btcusd).update_all(enabled: false)
      market = Market.find(:btcusd)
      market.update(enabled: false)
      market.valid?
      expect(market.errors[:market].size).to eq(1)
    end

    def to_readable(field)
      field.to_s.humanize.downcase
    end
  end
end
