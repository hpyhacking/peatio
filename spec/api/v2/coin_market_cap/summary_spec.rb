# frozen_string_literal: true

describe API::V2::CoinMarketCap::Summary, type: :request do
  describe 'GET /api/v2/coinmarketcap/summary' do
    before(:each) { clear_redis }
    after(:each) { delete_measurments('trades') }

    context 'There is no trades in influx' do
      it 'should return summary' do
        get '/api/v2/coinmarketcap/summary'

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result.count).to eq Market.all.count
        expect(result.first['trading_pairs']).to eq 'BTC_USD'
        expect(result.first['base_currency']).to eq 'BTC'
        expect(result.first['quote_currency']).to eq 'USD'
        expect(result.first['last_price']).to eq '0.0'
        expect(result.first['lowest_ask']).to eq '0.0'
        expect(result.first['highest_bid']).to eq '0.0'
        expect(result.first['base_volume']).to eq '0.0'
        expect(result.first['quote_volume']).to eq '0.0'
        expect(result.first['price_change_percent_24h']).to eq '0.0'
        expect(result.first['highest_price_24h']).to eq '0.0'
        expect(result.first['lowest_price_24h']).to eq '0.0'
      end
    end

    context 'There are trades in influx' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d)}
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d)}

      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      it 'should return summary' do
        get '/api/v2/coinmarketcap/summary'

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result.count).to eq Market.all.count
        expect(result.first['trading_pairs']).to eq 'BTC_USD'
        expect(result.first['base_currency']).to eq 'BTC'
        expect(result.first['quote_currency']).to eq 'USD'
        expect(result.first['last_price']).to eq '6.0'
        expect(result.first['lowest_ask']).to eq '1.0'
        expect(result.first['highest_bid']).to eq '1.0'
        expect(result.first['base_volume']).to eq '2.0'
        expect(result.first['quote_volume']).to eq '10.9'
        expect(result.first['price_change_percent_24h']).to eq '0.2'
        expect(result.first['highest_price_24h']).to eq '6.0'
        expect(result.first['lowest_price_24h']).to eq '5.0'
      end
    end

    context 'There is no markets' do
      before { DatabaseCleaner.clean }

      it 'should return summary' do
        get '/api/v2/coinmarketcap/summary'

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result).to eq []
      end
    end
  end
end
