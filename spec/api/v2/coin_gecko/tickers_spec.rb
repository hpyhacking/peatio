# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::CoinGecko::Tickers, type: :request do
  describe 'GET /api/v2/coingecko/tickers' do
    before(:each) { delete_measurments('trades') }
    after(:each) { delete_measurments('trades') }

    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd)
    end

    context 'no trades executed yet' do
      let(:expected_btcusd_ticker) do
        {
            'ticker_id' => 'BTC_USD',
            'base_currency' => 'BTC',
            'target_currency' => 'USD',
            'last_price' => '0.0',
            'target_volume' => '0.0', 'base_volume' => '0.0',
            'bid' => '1.0', 'ask' => '1.0',
            'high' => '0.0', 'low' => '0.0'
        }
      end

      let(:expected_btceth_ticker) do
        {
            'ticker_id' => 'BTC_ETH',
            'base_currency' => 'BTC',
            'target_currency' => 'ETH',
            'last_price' => '0.0',
            'target_volume' => '0.0', 'base_volume' => '0.0',
            'bid' => '0.0', 'ask' => '0.0',
            'high' => '0.0', 'low' => '0.0'
        }
      end

      it 'returns tickers of all markets' do
        get '/api/v2/coingecko/tickers'
        expect(response).to be_successful

        btc_usd_ticker = response_body.find {|ticker| ticker['ticker_id'] == 'BTC_USD'}
        btc_eth_ticker = response_body.find {|ticker| ticker['ticker_id'] == 'BTC_ETH'}
        expect(btc_usd_ticker).to eq expected_btcusd_ticker
        expect(btc_eth_ticker).to eq expected_btceth_ticker
      end
    end

    context 'single trade was executed' do
      let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}

      let(:expected_ticker) do
        {
            'ticker_id' => 'BTC_USD',
            'base_currency' => 'BTC',
            'target_currency' => 'USD',
            'last_price' => '5.0',
            'target_volume' => '5.5', 'base_volume' => '1.1',
            'bid' => '1.0', 'ask' => '1.0',
            'high' => '5.0', 'low' => '5.0'
        }
      end

      before do
        trade.write_to_influx
      end

      it 'returns tickers of all markets' do
        get '/api/v2/coingecko/tickers'
        expect(response).to be_successful

        btc_usd_ticker = response_body.find {|ticker| ticker['ticker_id'] == 'BTC_USD'}
        expect(btc_usd_ticker).to eq expected_ticker
      end
    end

    context 'multiple trades were executed' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      let(:expected_ticker) do
        {
            'ticker_id' => 'BTC_USD',
            'base_currency' => 'BTC',
            'target_currency' => 'USD',
            'last_price' => '6.0',
            'target_volume' => '10.9', 'base_volume' => '2.0',
            'bid' => '1.0', 'ask' => '1.0',
            'high' => '6.0', 'low' => '5.0'
        }
      end
      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'returns tickers of all markets' do
        get '/api/v2/coingecko/tickers'
        expect(response).to be_successful

        btc_usd_ticker = response_body.find {|ticker| ticker['ticker_id'] == 'BTC_USD'}
        expect(btc_usd_ticker).to eq expected_ticker
      end
    end
  end
end
