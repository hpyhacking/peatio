# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Tickers, type: :request do
  describe 'GET /api/v2/tickers' do
    # Clear Redis before each example.
    before { Rails.cache.instance_variable_get(:@data).flushall }
    after { Rails.cache.instance_variable_get(:@data).flushall }

    context 'no trades executed yet' do
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '0.0', 'high' => '0.0',
          'open' => '0.0', 'last' => '0.0',
          'volume' => '0.0', 'vol' => '0.0',
          'avg_price' => '0.0', 'price_change_percent' => '+0.00%' }
      end

      it 'returns ticker of all markets' do
        get '/api/v2/tickers'
        expect(response).to be_success
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to eq (expected_ticker)
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, price: '5.0'.to_d, volume: '1.1'.to_d, funds: '5.5'.to_d)}
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '5.0', 'high' => '5.0',
          'open' => '5.0', 'last' => '5.0',
          'volume' => '1.1', 'vol' => '1.1',
          'avg_price' => '5.0', 'price_change_percent' => '+0.00%' }
      end
      before do
        Worker::MarketTicker.new.process(trade.as_json, nil, nil)
      end

      it 'returns market tickers' do
        get '/api/v2/tickers'
        expect(response).to be_success
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to eq (expected_ticker)
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, price: '5.0'.to_d, volume: '1.1'.to_d, funds: '5.5'.to_d)}
      let!(:trade2) { create(:trade, price: '6.0'.to_d, volume: '0.9'.to_d, funds: '5.4'.to_d)}

      # open = 6.0 because it takes last by default.
      # to make it work correctly need to run k-line daemon.
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '5.0', 'high' => '6.0',
          'open' => '6.0', 'last' => '6.0',
          'vol' => '2.0', 'volume' => '2.0',
          'avg_price' => '5.5', 'price_change_percent' => '+0.00%' }
      end
      before do
        Worker::MarketTicker.new.process(trade1.as_json, nil, nil)
        Worker::MarketTicker.new.process(trade2.as_json, nil, nil)
      end

      it 'returns market tickers' do
        get '/api/v2/tickers'
        expect(response).to be_success
        expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
        expect(JSON.parse(response.body)['btcusd']['ticker']).to eq (expected_ticker)
      end
    end
  end

  describe 'GET /api/v2/tickers/:market' do
    # Clear Redis before each example.
    before { Rails.cache.instance_variable_get(:@data).flushall }
    after { Rails.cache.instance_variable_get(:@data).flushall }
    context 'no trades executed yet' do
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '0.0', 'high' => '0.0',
          'open' => '0.0', 'last' => '0.0',
          'volume' => '0.0', 'vol' => '0.0',
          'avg_price' => '0.0', 'price_change_percent' => '+0.00%'  }
      end

      it 'returns market tickers' do
        get '/api/v2/tickers/btcusd'
        expect(response).to be_success
        expect(JSON.parse(response.body)['ticker']).to eq (expected_ticker)
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, price: '5.0'.to_d, volume: '1.1'.to_d, funds: '5.5'.to_d)}
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '5.0', 'high' => '5.0',
          'open' => '5.0', 'last' => '5.0',
          'volume' => '1.1', 'vol' => '1.1',
          'avg_price' => '5.0', 'price_change_percent' => '+0.00%' }
      end
      before do
        Worker::MarketTicker.new.process(trade.as_json, nil, nil)
      end

      it 'returns market tickers' do
        get '/api/v2/tickers/btcusd'
        expect(response).to be_success
        expect(JSON.parse(response.body)['ticker']).to eq (expected_ticker)
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, price: '5.0'.to_d, volume: '1.1'.to_d, funds: '5.5'.to_d)}
      let!(:trade2) { create(:trade, price: '6.0'.to_d, volume: '0.9'.to_d, funds: '5.4'.to_d)}

      # open = 6.0 because it takes last by default.
      # to make it work correctly need to run k-line daemon.
      let(:expected_ticker) do
        { 'buy' => '0.0', 'sell' => '0.0',
          'low' => '5.0', 'high' => '6.0',
          'open' => '6.0', 'last' => '6.0',
          'vol' => '2.0', 'volume' => '2.0',
          'avg_price' => '5.5', 'price_change_percent' => '+0.00%' }
      end
      before do
        Worker::MarketTicker.new.process(trade1.as_json, nil, nil)
        Worker::MarketTicker.new.process(trade2.as_json, nil, nil)
      end

      it 'returns market tickers' do
        get '/api/v2/tickers/btcusd'
        expect(response).to be_success
        expect(JSON.parse(response.body)['ticker']).to eq (expected_ticker)
      end
    end
  end
end
