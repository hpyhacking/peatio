# frozen_string_literal: true

describe API::V2::CoinGecko::Orderbook, type: :request do
  describe 'GET /api/v2/coingecko/orderbook' do
    before do
      create_list(:order_bid, 5, :btcusd)
      create_list(:order_bid, 5, :btcusd, price: 2)
      create_list(:order_ask, 5, :btcusd)
      create_list(:order_ask, 5, :btcusd, price: 3)
    end

    let(:asks) { [["1.0", "5.0"], ["3.0", "5.0"]] }
    let(:bids) { [["2.0", "5.0"], ["1.0", "5.0"]] }

    context 'valid market param' do
      it 'sorts asks and bids from highest to lowest' do
        get "/api/v2/coingecko/orderbook", params: { ticker_id: "BTC_USD"}
        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['asks'].size).to eq 2
        expect(result['bids'].size).to eq 2
        expect(result['asks']).to eq asks
        expect(result['bids']).to eq bids
      end

      context 'with depth param' do
        before do
          create_list(:order_bid, 5, :btcusd)
          create_list(:order_bid, 5, :btcusd, price: 4.1)
          create_list(:order_ask, 5, :btcusd)
          create_list(:order_ask, 5, :btcusd, price: 12.2)
        end

        it 'get asks and bids with depth param' do
          get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 2 }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result['asks'].size).to eq 1
          expect(result['bids'].size).to eq 1
        end

        it 'get asks and bids with depth param' do
          get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 4 }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result['asks'].size).to eq 2
          expect(result['bids'].size).to eq 2
        end

        it 'get asks and bids with depth param' do
          get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 1 }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result['asks'].size).to eq 0
          expect(result['bids'].size).to eq 0
        end

        it 'get asks and bids with depth param' do
          get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 3 }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result['asks'].size).to eq 1
          expect(result['bids'].size).to eq 1
        end

        it 'get asks and bids with depth param for all orderbook' do
          get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 0 }
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result['asks'].size).to eq 3
          expect(result['bids'].size).to eq 3
        end

        context 'invalid depth params' do
          it 'shoud return error' do
            get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 'test' }
            expect(response).to have_http_status 422
            expect(response).to include_api_error('coingecko.market_depth.non_integer_depth')
          end

          it 'shoud return error' do
            get '/api/v2/coingecko/orderbook', params: { ticker_id: "BTC_USD", depth: 2000 }
            expect(response).to have_http_status 422
            expect(response).to include_api_error('coingecko.market_depth.invalid_depth')
          end
        end
      end
    end

    context 'invalid market param' do
      it 'validates market param' do
        get '/api/v2/coingecko/orderbook', params: { ticker_id: "usdusd" }
        expect(response).to have_http_status 404
        expect(response).to include_api_error('record.not_found')
      end
    end
  end
end
