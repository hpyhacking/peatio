describe Market do
  context 'visible market' do
    # it { expect(Market.orig_all.count).to eq(2) }
    it { expect(Market.all.count).to eq(1) }
  end

  context 'markets hash' do
    it 'should list all markets info' do
      expect(Market.to_hash).to eq ({ btccny: { name: 'BTC/CNY', base_unit: 'btc', quote_unit: 'cny' } })
    end
  end

  context 'market attributes' do
    let(:log) { Market.find('btccny') }

    it 'id' do
      expect(log.id).to eq 'btccny'
    end

    it 'name' do
      expect(log.name).to eq 'BTC/CNY'
    end

    it 'base_unit' do
      expect(log.base_unit).to eq 'btc'
    end

    it 'quote_unit' do
      expect(log.quote_unit).to eq 'cny'
    end

    it 'visible' do
      expect(log.visible).to be true
    end
  end

  context 'enumerize' do
    subject { Market.enumerize }

    it { is_expected.to be_has_key :btccny }
    it { is_expected.to be_has_key :ptsbtc }
  end

  context 'shortcut of global access' do
    let(:log) { Market.find('btccny') }

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
