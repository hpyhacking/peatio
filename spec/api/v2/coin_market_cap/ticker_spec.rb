# frozen_string_literal: true

describe API::V2::CoinMarketCap::Ticker, type: :request do
  describe 'GET /api/v2/coinmarketcap/ticker' do
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd)
    end

    before(:each) { clear_redis }

    context 'with unified id' do
      before(:each) { delete_measurments('trades') }
      after(:each) { delete_measurments('trades') }

      before do
        Currency.ordered.coins.each.with_index(1) do |currency, index|
          stub_request(:get, "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?CMC_PRO_API_KEY=UNIFIED-CRYPTOASSET-INDEX&"\
                                                                                    "listing_status=active&"\
                                                                                    "symbol=#{currency.id}")
            .to_return(body:
              {
                'status'=>
                    {
                      'error_code'=>0,
                      'error_message'=>nil,
                      'elapsed'=>12,
                      'credit_count'=>1,
                      'notice'=>nil
                    },
                'data'=>
                  [
                    {
                      'id'=>index
                    }
                  ]
              }.to_json)
        end
      end

      context 'no trades executed yet' do
        let(:expected_btc_usd_ticker) do
          {
            'base_id' => 1, 'last_price' => '0.0',
            'quote_volume' => '0.0', 'base_volume' => '0.0',
            'isFrozen' => 0 }
        end

        let(:expected_btc_eth_ticker) do
          {
            'base_id' => 1, 'quote_id' => 2, 'last_price' => '0.0',
            'quote_volume' => '0.0', 'base_volume' => '0.0',
            'isFrozen' => 0 }
        end

        it 'returns ticker of all markets' do
          get '/api/v2/coinmarketcap/ticker'
          expect(response).to be_successful

          # crypto/fiat market
          expect(response_body['BTC_USD'].keys).to match_array %w[base_id last_price base_volume quote_volume isFrozen]
          expect(response_body['BTC_USD']).to include(expected_btc_usd_ticker)
          # crypto/crypto market
          expect(response_body['BTC_ETH'].keys).to match_array %w[base_id quote_id last_price base_volume quote_volume isFrozen]
          expect(response_body['BTC_ETH']).to include(expected_btc_eth_ticker)
        end
      end

      context 'single trade was executed' do
        let!(:trade) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}

        let(:expected_btc_usd_ticker) do
          {
            'base_id' => 1,
            'last_price' => '5.0', 'quote_volume' => '5.5',
            'base_volume' => '1.1', 'isFrozen' => 0
          }
        end

        let(:expected_btc_usd_frozen_ticker) do
          {
            'base_id' => 1, 'last_price' => '5.0',
            'quote_volume' => '5.5', 'base_volume' => '1.1', 'isFrozen' => 1
          }
        end

        before do
          trade.write_to_influx
        end

        it 'returns market tickers' do
          get '/api/v2/coinmarketcap/ticker'

          expect(response).to be_successful
          # crypto/fiat market
          expect(response_body['BTC_USD'].keys).to match_array %w[base_id last_price base_volume quote_volume isFrozen]
          expect(response_body['BTC_USD']).to include(expected_btc_usd_ticker)
        end
      end

      context 'multiple trades were executed' do
        let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
        let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

        let(:expected_btc_usd_ticker) do
          { 'base_id' => 1, 'last_price' => '6.0',
            'quote_volume' => '10.9', 'base_volume' => '2.0',
            'isFrozen' => 0 }
        end

        before do
          trade1.write_to_influx
          trade2.write_to_influx
        end

        it 'returns market tickers' do
          get '/api/v2/coinmarketcap/ticker'
          expect(response).to be_successful

          # crypto/fiat market
          expect(response_body['BTC_USD'].keys).to match_array %w[base_id last_price base_volume quote_volume isFrozen]
          expect(response_body['BTC_USD']).to include(expected_btc_usd_ticker)
        end
      end
    end
  end
end
