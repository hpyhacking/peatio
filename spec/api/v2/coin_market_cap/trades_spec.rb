# frozen_string_literal: true

describe API::V2::CoinMarketCap::Trades, type: :request do
  describe 'GET /api/v2/coinmarketcap/trades/:market_pair' do
    before(:each) { delete_measurments('trades') }
    after(:each) { delete_measurments('trades') }

    context 'there is no market pair' do
      it 'should return error' do
        get '/api/v2/coinmarketcap/trades/TEST_TEST'

        expect(response).to have_http_status 404
        expect(response).to include_api_error('record.not_found')
      end
    end

    context 'there is no trades in influx' do
      it 'should return recent trades' do
        get '/api/v2/coinmarketcap/trades/BTC_USD'

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result).to eq []
      end
    end

    context 'there are trades in influx' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'should return recent trades' do
        get '/api/v2/coinmarketcap/trades/BTC_USD'

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result.count).to eq 2
        expect(result.first.keys).to match_array %w[trade_id price base_volume quote_volume timestamp type]
        expect(result.first['trade_id']).to eq trade2.id
        expect(result.first['price']).to eq trade2.price
        expect(result.first['base_volume']).to eq trade2.amount
        expect(result.first['quote_volume']).to eq trade2.total
        expect(result.first['type']).to eq trade2.taker_type
      end
    end
  end
end
