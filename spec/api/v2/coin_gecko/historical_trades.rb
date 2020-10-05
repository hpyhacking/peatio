# frozen_string_literal: true

describe API::V2::CoinGecko::HistoricalTrades, type: :request do
  describe 'GET /api/v2/coingecko/historical_trades' do
    before(:each) { delete_measurments('trades') }
    after(:each) { delete_measurments('trades') }

    context 'there is no market pair' do
      it 'should return error' do
        get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'TEST_TEST' }

        expect(response).to have_http_status 404
        expect(response).to include_api_error('record.not_found')
      end
    end

    context 'there is no trades in influx' do
      let(:expected_response) do
        {
          'buy' => [],
          'sell' => []
        }
      end

      it 'should return recent trades' do
        get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD' }

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result).to eq expected_response
      end
    end

    context 'there are trades in influx' do
      let!(:trade1) { create(:trade, :btcusd, price: '5.0'.to_d, amount: '1.1'.to_d, total: '5.5'.to_d, created_at: Time.now) }
      let!(:trade2) { create(:trade, :btcusd, price: '6.0'.to_d, amount: '0.9'.to_d, total: '5.4'.to_d, created_at: Time.now + 1.month) }

      before do
        trade1.write_to_influx
        trade2.write_to_influx
      end

      context 'return all trades' do
        let(:expected_response) do
          {
            'buy' => [
              {'base_volume' => 0.9,
               'price' => 6,
               'target_volume' => 5.4,
               'trade_id' => trade2.id,
               'trade_timestamp' => trade2.created_at.to_i * 1000,
               'type' => 'buy'},

              {'base_volume' => 1.1,
               'price' => 5,
               'target_volume' => 5.5,
               'trade_id' => trade1.id,
               'trade_timestamp' => trade1.created_at.to_i * 1000,
               'type' => 'buy'}
            ],
            'sell' => []
          }
        end

        it do
          get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD'}
          expect(response).to be_successful

          expect(response_body).to eq expected_response
        end
      end

      context 'return filtered trades' do
        let(:expected_response) do
          {
            'buy' => [
              {'base_volume' => 0.9,
               'price' => 6,
               'target_volume' => 5.4,
               'trade_id' => trade2.id,
               'trade_timestamp' => trade2.created_at.to_i * 1000,
               'type' => 'buy'},

              {'base_volume' => 1.1,
               'price' => 5,
               'target_volume' => 5.5,
               'trade_id' => trade1.id,
               'trade_timestamp' => trade1.created_at.to_i * 1000,
               'type' => 'buy'}
            ],
            'sell' => []
          }
        end

        context 'by taker_type' do
          it 'buy' do
            get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', type: 'buy'}
            expect(response).to be_successful

            expect(response_body).to eq expected_response
          end

          it 'sell' do
            get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', type: 'sell'}
            expect(response).to be_successful

            expect(response_body).to eq({'buy'=> [], 'sell' => []})
          end
        end


        context 'by start time' do

          let(:expected_response) do
            {
                'buy' => [
                    {'base_volume' => 0.9,
                     'price' => 6,
                     'target_volume' => 5.4,
                     'trade_id' => trade2.id,
                     'trade_timestamp' => trade2.created_at.to_i * 1000,
                     'type' => 'buy'}
                ],
                'sell' => []
            }
          end

          it do
            get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', start_time: Time.now + 15.days}
            expect(response).to be_successful

            expect(response_body).to eq expected_response
          end
        end

        context 'by end time' do

          let(:expected_response) do
            {
                'buy' => [
                    {'base_volume' => 1.1,
                     'price' => 5,
                     'target_volume' => 5.5,
                     'trade_id' => trade1.id,
                     'trade_timestamp' => trade1.created_at.to_i * 1000,
                     'type' => 'buy'}
                ],
                'sell' => []
            }
          end

          it do
            get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', end_time: Time.now + 15.days}
            expect(response).to be_successful

            expect(response_body).to eq expected_response
          end
        end

        context 'by limit' do
          context 'without specified limit' do
            let(:expected_response) do
              {
                  'buy' => [
                      {'base_volume' => 0.9,
                       'price' => 6,
                       'target_volume' => 5.4,
                       'trade_id' => trade2.id,
                       'trade_timestamp' => trade2.created_at.to_i * 1000,
                       'type' => 'buy'},

                      {'base_volume' => 1.1,
                       'price' => 5,
                       'target_volume' => 5.5,
                       'trade_id' => trade1.id,
                       'trade_timestamp' => trade1.created_at.to_i * 1000,
                       'type' => 'buy'}
                  ],
                  'sell' => []
              }
            end

            it 'returns all trades' do
              get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD'}
              expect(response).to be_successful

              expect(response_body).to eq expected_response
            end
          end

          context 'with specified limit' do
            let(:expected_response) do
              {
                  'buy' => [
                      {'base_volume' => 0.9,
                       'price' => 6,
                       'target_volume' => 5.4,
                       'trade_id' => trade2.id,
                       'trade_timestamp' => trade2.created_at.to_i * 1000,
                       'type' => 'buy'}
                  ],
                  'sell' => []
              }
            end

            it 'returns specific number of trades' do
              get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', limit: 1}
              expect(response).to be_successful

              expect(response_body).to eq expected_response
            end
          end

          context 'with limit==0' do
            let(:expected_response) do
              {
                  'buy' => [
                      {'base_volume' => 0.9,
                       'price' => 6,
                       'target_volume' => 5.4,
                       'trade_id' => trade2.id,
                       'trade_timestamp' => trade2.created_at.to_i * 1000,
                       'type' => 'buy'},

                      {'base_volume' => 1.1,
                       'price' => 5,
                       'target_volume' => 5.5,
                       'trade_id' => trade1.id,
                       'trade_timestamp' => trade1.created_at.to_i * 1000,
                       'type' => 'buy'}
                  ],
                  'sell' => []
              }
            end

            it 'returns all trades' do
              get '/api/v2/coingecko/historical_trades', params: { ticker_id: 'BTC_USD', limit: 0}
              expect(response).to be_successful

              expect(response_body).to eq expected_response
            end
          end
        end
      end
    end
  end
end
