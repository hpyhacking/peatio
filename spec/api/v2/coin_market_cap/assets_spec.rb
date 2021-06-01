# frozen_string_literal: true

describe API::V2::CoinMarketCap::Assets, type: :request do
  describe 'GET /api/v2/coinmarketcap/assets' do
    before(:each) { clear_redis }

    context 'There are currencies' do
      context 'with unified id' do
        before do
          Currency.coins.each do |currency|
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
                        'id'=>1
                      }
                    ]
                }.to_json)
          end
        end

        it 'should return crypto assets' do
          get '/api/v2/coinmarketcap/assets'
          expect(response).to be_successful
          expect(response_body['BTC'].keys).to match_array %w[name unified_cryptoasset_id]
          expect(response_body['BTC']['name']).to eq 'Bitcoin'
          expect(response_body['BTC']['unified_cryptoasset_id']).to eq 1
        end
      end

      context 'without unified id' do
        before do
          Currency.coins.each do |currency|
            stub_request(:get, "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?CMC_PRO_API_KEY=UNIFIED-CRYPTOASSET-INDEX&"\
                                                                                      "listing_status=active&"\
                                                                                      "symbol=#{currency.id}")
              .to_return(status: 400, body:
                {
                  'status'=>
                    {
                      'timestamp'=>'2020-09-25T08:43:56.778Z',
                      'error_code'=>400,
                      'error_message'=>'Invalid value for \'symbol\': \'TESTTEST\'',
                      'elapsed'=>0,
                      'credit_count'=>0,
                      'notice'=>nil
                    }
                }.to_json)
          end
        end

        it 'should return crypto assets' do
          get '/api/v2/coinmarketcap/assets'

          expect(response).to be_successful
          expect(response_body['BTC'].keys).to match_array %w[name]
          expect(response_body['BTC']['name']).to eq 'Bitcoin'
        end

        context 'with 500 error from Faraday' do
          before do
            Currency.coins.each do |currency|
              stub_request(:get, "https://pro-api.coinmarketcap.com/v1/cryptocurrency/map?CMC_PRO_API_KEY=UNIFIED-CRYPTOASSET-INDEX&"\
                                                                                        "listing_status=active&"\
                                                                                        "symbol=#{currency.id}")
                  .to_raise(Faraday::Error)
            end
          end

          it 'should return crypto assets' do
            get '/api/v2/coinmarketcap/assets'

            expect(response).to be_successful
            expect(response_body['BTC'].keys).to match_array %w[name]
            expect(response_body['BTC']['name']).to eq 'Bitcoin'
          end
        end
      end
    end

    context 'There is no currencies' do
      before { DatabaseCleaner.clean }

      it 'should return assets' do
        get '/api/v2/coinmarketcap/assets'

        expect(response).to be_successful
        expect(response_body).to eq({})
      end
    end
  end
end
