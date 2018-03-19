describe Market do
  context 'visible market' do
    # it { expect(Market.orig_all.count).to eq(2) }
    it { expect(Market.all.count).to eq(1) }
  end

  context 'markets hash' do
    it 'should list all markets info' do
      expect(Market.to_hash).to eq ({ btcusd: { name: 'BTC/USD', base_unit: 'btc', quote_unit: 'usd' } })
    end
  end

  context 'market attributes' do
    let(:log) { Market.find('btcusd') }

    it 'id' do
      expect(log.id).to eq 'btcusd'
    end

    it 'name' do
      expect(log.name).to eq 'BTC/USD'
    end

    it 'base_unit' do
      expect(log.base_unit).to eq 'btc'
    end

    it 'quote_unit' do
      expect(log.quote_unit).to eq 'usd'
    end

    it 'visible' do
      expect(log.visible).to be true
    end
  end

  context 'enumerize' do
    subject { Market.enumerize }

    it { is_expected.to be_has_key :btcusd }
    it { is_expected.to be_has_key :dashbtc }
  end

  context 'shortcut of global access' do
    let(:log) { Market.find('btcusd') }

    it 'bids' do
      expect(log.bids).to be
    end

    it 'asks' do
      expect(log.asks).to be
    end

    it 'trades' do
      expect(log.trades).to be
    end

    it 'ticker' do
      expect(log.ticker).to be
    end
  end
end
