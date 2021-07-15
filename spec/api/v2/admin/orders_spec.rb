# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Orders, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/orders' do
    before do
      # NOTE: We specify updated_at attribute for testing order of Order.
      create(:order_bid, :btcusd, price: '11'.to_d, origin_volume: '123.12', member: admin, updated_at: Time.at(1548224524), created_at: Time.at(1548234524))
      create(:order_bid, :btceth, price: '11'.to_d, origin_volume: '123.12', member: admin, updated_at: Time.at(1548234524), created_at: Time.at(1548254524))
      create(:order_bid, :btceth_qe, price: '11'.to_d, origin_volume: '123.12', member: admin, updated_at: Time.at(1548234524), created_at: Time.at(1548254524))
      create(:order_bid, :btcusd, price: '12'.to_d, origin_volume: '123.12', member: admin, state: Order::CANCEL, updated_at: Time.at(1548244524), created_at: Time.at(1548254524))
      create(:order_ask, :btcusd, price: '13'.to_d, origin_volume: '123.12', member: admin, state: Order::WAIT, updated_at: Time.at(1548254524), created_at: Time.at(1548254524))
      create(:order_ask, :btcusd, price: '14'.to_d, origin_volume: '123.12', member: admin, state: Order::DONE, created_at: Time.at(1548254524))
    end

    it 'csv export' do
      api_get'/api/v2/admin/orders', token: token, params: { format: :csv }
      expect(response).to be_successful
    end

    it 'requires authentication' do
      get '/api/v2/admin/orders', params: { market: 'btcusd' }
      expect(response.code).to eq '401'
    end

    it 'validates market param' do
      api_get '/api/v2/admin/orders', params: { market: 'usdusd' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.doesnt_exist')
    end

    it 'validates limit param' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', limit: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.pagination.invalid_limit')
    end

    it 'validates price param' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', price: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.order.non_positive_price')
    end

    it 'validates origin_volume param' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', origin_volume: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.order.non_positive_origin_volume')
    end

    it 'validates page param' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', limit: 2, page: "page 2" }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.pagination.non_integer_page')
    end

    it 'validates ord_type param' do
      api_get '/api/v2/admin/orders', params: { ord_type: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.order.invalid_ord_type')
    end

    it 'returns orders with state done' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', state: Order::DONE }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(result.first['state']).to eq Order::DONE
    end

    it 'returns all my orders for btcusd market' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 4
    end

    it 'returns all my orders for btceth spot market' do
      api_get '/api/v2/admin/orders', params: { market: 'btceth' }, token: token
      expected = Order.spot.with_market('btceth').pluck(:market_type)
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.pluck('market_type')).to match_array expected
      expect(result.size).to eq 1
    end

    it 'returns all my orders for btceth qe market' do
      api_get '/api/v2/admin/orders', params: { market: 'btceth', market_type: 'qe' }, token: token
      expected = Order.qe.with_market('btceth').pluck(:market_type)
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.pluck('market_type')).to match_array expected
      expect(result.size).to eq 1
    end

    it 'returns orders with ord_type limit' do
      api_get '/api/v2/admin/orders', params: { ord_type: 'limit' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['ord_type']}).to all eq 'limit'
    end

    it 'returns orders with type sell' do
      api_get '/api/v2/admin/orders', params: { type: 'sell' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['side']}).to all eq 'sell'
    end

    it 'returns orders for specific price' do
      api_get '/api/v2/admin/orders', params: { price: '11'.to_d }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['price']}.size).to eq 2
      expect(result.map{|r| r['price']}).to all eq '11.0'
    end

    it 'returns orders for specific origin_volume' do
      api_get '/api/v2/admin/orders', params: { origin_volume: '123.12' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['origin_volume']}.size).to eq 5
      expect(result.map{|r| r['origin_volume']}).to all eq '123.12'
    end

    it 'returns orders for specific user by email' do
      api_get '/api/v2/admin/orders', params: { email: 'example@gmail.com' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['email']}.size).to eq 5
      expect(result.map{|r| r['email']}).to all eq 'example@gmail.com'
    end

    it 'returns orders for specific user by uid' do
      api_get '/api/v2/admin/orders', params: { uid: 'ID73BF61C8H0' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['uid']}.size).to eq 5
      expect(result.map{|r| r['uid']}).to all eq 'ID73BF61C8H0'
    end

    it 'returns paginated orders' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', limit: 1, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(result.first['price']).to eq '14.0'

      api_get '/api/v2/admin/orders', params: { market: 'btcusd', limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(result.first['price']).to eq '13.0'
    end

    it 'returns orders by ascending order' do
      api_get '/api/v2/admin/orders', params: { market: 'btcusd', ordering: 'asc', order_by: 'updated_at'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['price']).to eq '11.0'
    end

    it 'returns orders for updated time range' do
      api_get '/api/v2/admin/orders', params: { range: 'updated', from: Time.at(1548224524).iso8601, to: Time.at(1548244524).iso8601 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 3
    end

    it 'return error in case of not permitted ability' do
      api_get'/api/v2/admin/orders', token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/orders/:id/cancel' do
    let!(:order) { create(:order_bid, :btcusd, price: '12.32'.to_d, volume: '3.14', origin_volume: '12.13', locked: '20.1082', origin_locked: '38.0882', member: level_3_member) }

    before do
      level_3_member.get_account(:usd).update_attributes(locked: order.price * order.volume)
    end

    it 'should cancel specified order' do
      AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)
      expect do
        api_post "/api/v2/admin/orders/#{order.id}/cancel", token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result['id']).to eq order.id
      end.not_to change(Order, :count)
    end

    it 'return error in case of non existent order' do
      api_post '/api/v2/admin/orders/0/cancel', token: token
      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/orders/0/cancel', token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/orders/cancel' do
    before do
      create(:order_ask, :btcusd, price: '12.32', volume: '3.14', origin_volume: '12.13', member: level_3_member)
      create(:order_bid, :btcusd, price: '12.32', volume: '3.14', origin_volume: '12.13', member: level_3_member)
      create(:order_bid, :btceth, price: '12.32', volume: '3.14', origin_volume: '12.13', member: level_3_member)

      level_3_member.get_account(:btc).update_attributes(locked: '5')
      level_3_member.get_account(:usd).update_attributes(locked: '50')
    end

    it 'should cancel all my orders for specific market' do
      level_3_member.orders.where(market: 'btceth').each do |o|
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: o.to_matching_attributes)
      end

      expect do
        api_post '/api/v2/admin/orders/cancel', token: token, params: { market: 'btceth' }
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.size).to eq 1
      end.not_to change(Order, :count)
    end

    it 'should cancel all asks for specific market' do
      level_3_member.orders.where(type: 'OrderAsk', market_id: 'btcusd').each do |o|
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: o.to_matching_attributes)
      end

      expect do
        api_post '/api/v2/admin/orders/cancel', token: token, params: { market: 'btcusd', side: 'sell' }
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result.size).to eq 1
        expect(result.first['id']).to eq level_3_member.orders.where(type: 'OrderAsk').first.id
      end.not_to change(Order, :count)
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/orders/cancel', token: level_3_member_token, params: { market: 'btceth' }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'return error in case of invalid order type' do
      api_post '/api/v2/admin/orders/cancel', token: token, params: { market: 'btceth', side: 'ask' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.order.invalid_side')
    end

    it 'return error in case of invalid market' do
      api_post '/api/v2/admin/orders/cancel', token: token, params: { market: 'testusd' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.order.market_doesnt_exist')
    end
  end
end
