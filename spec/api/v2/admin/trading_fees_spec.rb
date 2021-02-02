# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::TradingFees, type: :request do

  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H1') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /trading_fees' do
    before do
      create(:trading_fee, maker: 0.0005, taker: 0.001, market_id: :btcusd, group: 'vip-0')
      create(:trading_fee, maker: 0.0008, taker: 0.001, market_id: :any, group: 'vip-0')
      create(:trading_fee, maker: 0.001, taker: 0.0012, market_id: :btcusd, group: :any)
    end

    it 'returns all trading fees' do
      api_get '/api/v2/admin/trading_fees', token: token

      expect(response.status).to eq 200
      expect(JSON.parse(response.body).length).to eq TradingFee.count
    end

    it 'pagination' do
      api_get '/api/v2/admin/trading_fees', token: token, params: { limit: 1 }
      expect(JSON.parse(response.body).length).to eq 1
    end

    it 'filters by market_id' do
      api_get '/api/v2/admin/trading_fees', token: token, params: { market_id: 'btcusd' }

      result = JSON.parse(response.body)
      expect(result.map { |r| r['market_id'] }).to all eq 'btcusd'
      expect(result.length).to eq TradingFee.where(market_id: 'btcusd').count
    end

    it 'filters by group' do
      api_get '/api/v2/admin/trading_fees', token: token, params: { group: 'vip-0' }

      result = JSON.parse(response.body)
      expect(result.map { |r| r['group'] }).to all eq 'vip-0'
      expect(result.length).to eq TradingFee.where(group: 'vip-0').count
    end

    it 'capitalized fee group' do
      api_get '/api/v2/admin/trading_fees', token: token, params: { group: 'Vip-0' }

      result = JSON.parse(response.body)
      expect(result.map { |r| r['group'] }).to all eq 'vip-0'
      expect(result.length).to eq TradingFee.where(group: 'vip-0').count
    end
  end

  describe 'POST /trading_fees/new' do
    it 'creates a table with default group' do
      api_post '/api/v2/admin/trading_fees/new', token: token, params: { maker: 0.001, taker: 0.0015, market_id: 'btcusd' }

      expect(response).to be_successful
      expect(JSON.parse(response.body)['maker']).to eq('0.001')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('any')
      expect(JSON.parse(response.body)['market_id']).to eq('btcusd')
    end

    it 'creates a table with default market' do
      api_post '/api/v2/admin/trading_fees/new', token: token, params: { group: 'vip-1', maker: 0.001, taker: 0.0015 }

      expect(response).to be_successful
      expect(JSON.parse(response.body)['maker']).to eq('0.001')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('vip-1')
      expect(JSON.parse(response.body)['market_id']).to eq('any')
    end

    it 'returns created trading fee table' do
      api_post '/api/v2/admin/trading_fees/new', token: token, params: { group: 'vip-1', market_id: 'btcusd', maker: 0.001, taker: 0.0015 }

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['maker']).to eq('0.001')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('vip-1')
      expect(JSON.parse(response.body)['market_id']).to eq('btcusd')
    end

    context 'returns created trading fee table without group' do
      it 'returns created trading fee table' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { market_id: 'btcusd', maker: 0.001, taker: 0.0015 }

        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)['maker']).to eq('0.001')
        expect(JSON.parse(response.body)['taker']).to eq('0.0015')
        expect(JSON.parse(response.body)['group']).to eq('any')
        expect(JSON.parse(response.body)['market_id']).to eq('btcusd')
      end
    end

    context 'returns created trading fee table without market_id' do
      it 'returns created trading fee table' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { maker: 0.001, taker: 0.0015, group: 'vip-1' }

        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)['maker']).to eq('0.001')
        expect(JSON.parse(response.body)['taker']).to eq('0.0015')
        expect(JSON.parse(response.body)['group']).to eq('vip-1')
        expect(JSON.parse(response.body)['market_id']).to eq('any')
      end
    end

    context 'invalid market_id' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { maker: 0.001, taker: 0.0015, market_id: 'uahusd' }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.market_doesnt_exist')
      end
    end

    context 'empty maker field' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { taker: 0.0015, group: 'vip-1', market_id: 'btcusd' }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.invalid_maker')
      end
    end

    context 'empty taker field' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { maker: 0.0015, group: 'vip-1', market_id: 'btcusd' }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.invalid_taker')
      end
    end

    context 'invalid maker/taker type' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { taker: -0.1, maker: -0.15, group: 'vip-1', market_id: 'btcusd' }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.invalid_maker')
        expect(response).to include_api_error('admin.trading_fee.invalid_taker')
      end
    end

    context 'invalid maker/taker fee' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/new', token: token, params: { taker: 1, maker: 1, group: 'vip-1', market_id: 'btcusd' }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('Maker must be less than or equal to 0.5')
        expect(response).to include_api_error('Taker must be less than or equal to 0.5')
      end
    end
  end

  describe 'POST /trading_fees/update' do
    it 'returns updated trading fee table with new group' do
      api_post '/api/v2/admin/trading_fees/update', token: token, params: { group: 'vip-1', id: TradingFee.first.id }

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['maker']).to eq('0.0015')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('vip-1')
      expect(JSON.parse(response.body)['market_id']).to eq('any')
    end

    it 'returns updated trading fee table with new group with capitalized letter' do
      api_post '/api/v2/admin/trading_fees/update', token: token, params: { group: 'Vip-1 ', id: TradingFee.first.id }

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['maker']).to eq('0.0015')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('vip-1')
      expect(JSON.parse(response.body)['market_id']).to eq('any')
    end

    it 'returns updated trading fee table with new maker' do
      api_post '/api/v2/admin/trading_fees/update', token: token, params: { market_id: 'btcusd', id: TradingFee.first.id }

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['maker']).to eq('0.0015')
      expect(JSON.parse(response.body)['taker']).to eq('0.0015')
      expect(JSON.parse(response.body)['group']).to eq('any')
      expect(JSON.parse(response.body)['market_id']).to eq('btcusd')
    end

    it 'returns updated trading fee table with new maker, taker fields' do
      api_post '/api/v2/admin/trading_fees/update', token: token, params: { maker: 0.1, taker: 0.1, id: TradingFee.first.id }

      expect(response).to have_http_status(201)
      expect(JSON.parse(response.body)['maker']).to eq('0.1')
      expect(JSON.parse(response.body)['taker']).to eq('0.1')
      expect(JSON.parse(response.body)['group']).to eq('any')
      expect(JSON.parse(response.body)['market_id']).to eq('any')
    end

    context 'not found trading_fee table' do
      it 'returns status 404 and error' do
        api_post '/api/v2/admin/trading_fees/update', token: token, params: { id: TradingFee.last.id + 1 }

        expect(response).to have_http_status(404)
        expect(response).to include_api_error('record.not_found')
      end
    end

    context 'empty maker type' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/update', token: token, params: { maker: -1, id: TradingFee.first.id }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.invalid_maker')
      end
    end

    context 'empty taker type' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/update', token: token, params: { taker: -1, id: TradingFee.first.id }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.invalid_taker')
      end
    end

    context 'invalid maker/taker type' do
      it 'returns status 422 and error' do
        api_post '/api/v2/admin/trading_fees/update', token: token, params: { market_id: 'uahusd', id: TradingFee.first.id }

        expect(response).to have_http_status(422)
        expect(response).to include_api_error('admin.trading_fee.market_doesnt_exist')
      end
    end
  end

  describe 'POST /trading_fees/delete' do
    let!(:trading_fee) { create(:trading_fee) }

    it 'requires id' do
      api_post '/api/v2/admin/trading_fees/delete', token: token
      expect(response).to include_api_error 'admin.tradingfee.missing_id'
    end

    it 'deletes trading fee table' do
      expect {
        api_post '/api/v2/admin/trading_fees/delete', token: token, params: { id: trading_fee.id }
      }.to change { TradingFee.count }.by(-1)

      expect(response).to have_http_status(201)
    end

    it 'returns deleted trading fee table' do
      api_post '/api/v2/admin/trading_fees/delete', token: token, params: { id: trading_fee.id }

      expect(JSON.parse(response.body)['id']).to eq trading_fee.id
    end

    it 'retuns 404 if record does not exist' do
      expect {
        api_post '/api/v2/admin/trading_fees/delete', token: token, params: { id: TradingFee.last.id + 42 }
      }.not_to change { TradingFee.count }

      expect(response.status).to eq 404
    end
  end
end
