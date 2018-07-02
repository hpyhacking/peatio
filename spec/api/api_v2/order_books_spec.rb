# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::OrderBooks, type: :request do
  describe 'GET /api/v2/order_book' do
    before do
      5.times { create(:order_bid) }
      5.times { create(:order_ask) }
    end

    it 'should return ask and bid orders on specified market' do
      get '/api/v2/order_book', market: 'btcusd'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result['asks'].size).to eq 5
      expect(result['bids'].size).to eq 5
    end

    it 'should return limited asks and bids' do
      get '/api/v2/order_book', market: 'btcusd', asks_limit: 1, bids_limit: 1
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result['asks'].size).to eq 1
      expect(result['bids'].size).to eq 1
    end
  end

  describe 'GET /api/v2/depth' do
    let(:asks) { [['100', '2.0'], ['120', '1.0']] }
    let(:bids) { [['90', '3.0'], ['50', '1.0']] }

    context 'valid market param' do
      before do
        global = mock('global', asks: asks, bids: bids)
        Global.stubs(:[]).returns(global)
      end

      it 'should sort asks and bids from highest to lowest' do
        get '/api/v2/depth', market: 'btcusd'
        expect(response).to be_success

        result = JSON.parse(response.body)
        expect(result['asks']).to eq asks.reverse
        expect(result['bids']).to eq bids
      end
    end

    context 'invalid market param' do
      it 'should validate market param' do
        api_get '/api/v2/depth', params: { market: 'usdusd' }
        expect(response).to have_http_status 422
        expect(JSON.parse(response.body)).to eq ({ 'error' => { 'code' => 1001, 'message' => 'market does not have a valid value' } })
      end
    end
  end
end
