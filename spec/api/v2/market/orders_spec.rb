# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Market::Orders, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:token) { jwt_for(member) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['Order'],'create'=>['Order'],'update'=>['Order']}})
  end

  describe 'GET /api/v2/market/orders' do
    before do
      # NOTE: We specify updated_at attribute for testing order of Order.
      create(:order_bid, :btcusd, price: '11'.to_d, volume: '123.12345678', member: member, created_at: 1.day.ago, updated_at: Time.now + 5)
      create(:order_bid, :btceth, price: '11'.to_d, volume: '123.1234', member: member)
      create(:order_bid, :btcusd, price: '12'.to_d, volume: '123.12345678', created_at: 1.day.ago, member: member, state: Order::CANCEL)
      create(:order_ask, :btcusd, price: '13'.to_d, volume: '123.12345678', created_at: 2.hours.ago, member: member, state: Order::WAIT, updated_at: Time.now + 10)
      create(:order_ask, :btcusd, price: '14'.to_d, volume: '123.12345678', created_at: 6.hours.ago, member: member, state: Order::DONE)
    end

    it 'requires authentication' do
      get '/api/v2/market/orders', params: { market: 'btcusd' }
      expect(response.code).to eq '401'
    end

    it 'validates market param' do
      api_get '/api/v2/market/orders', params: { market: 'usdusd' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('market.market.doesnt_exist')
    end

    it 'validates state param' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', state: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_state')
    end

    it 'validates limit param' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', limit: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_limit')
    end

    it 'validates ord_type param' do
      api_get '/api/v2/market/orders', params: { ord_type: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_ord_type')
    end

    it 'validates type param' do
      api_get '/api/v2/market/orders', params: { type: 'test' }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_type')
    end

    it 'returns all order history' do
      api_get '/api/v2/market/orders', token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 5
    end

    it 'returns all my orders for btcusd market' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 4
    end

    it 'returns orders for several markets' do
      api_get '/api/v2/market/orders', params: { market: ['btcusd', 'btceth'] }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 5
    end

    it 'returns orders with state done' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', state: Order::DONE }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(result.first['state']).to eq Order::DONE
    end

    it 'returns orders with state done and wait' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', state: [Order::DONE, Order::WAIT] }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      count = member.orders.where(state: [Order::DONE, Order::WAIT], market_id: 'btcusd').count
      expect(result.size).to eq count
    end

    it 'returns paginated orders' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', limit: 1, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['price']).to eq '13.0'

      api_get '/api/v2/market/orders', params: { market: 'btcusd', limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['price']).to eq '11.0'
    end

    it 'returns sorted orders' do
      api_get '/api/v2/market/orders', params: { market: 'btcusd', order_by: 'asc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      first_order_updated_at = Time.iso8601(result.first['updated_at'])
      second_order_updated_at = Time.iso8601(result.second['updated_at'])
      expect(first_order_updated_at).to be <= second_order_updated_at

      api_get '/api/v2/market/orders', params: { market: 'btcusd', order_by: 'desc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      first_order_updated_at = Time.iso8601(result.first['updated_at'])
      second_order_updated_at = Time.iso8601(result.second['updated_at'])
      expect(first_order_updated_at).to be >= second_order_updated_at
    end

    it 'returns orders with ord_type limit' do
      api_get '/api/v2/market/orders', params: { ord_type: 'limit' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['ord_type']}.uniq.size).to eq 1
      expect(result.map{|r| r['ord_type']}.uniq.first).to eq 'limit'
    end

    it 'returns orders with type sell' do
      api_get '/api/v2/market/orders', params: { type: 'sell' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.map{|r| r['side']}.uniq.size).to eq 1
      expect(result.map{|r| r['side']}.uniq.first).to eq 'sell'
    end

    it 'returns orders with base unit btc' do
      api_get '/api/v2/market/orders', params: { base_unit: 'btc' }, token: token

      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 5
    end

    it 'returns orders with quote unit eth' do
      api_get '/api/v2/market/orders', params: { base_unit: 'btc' }, token: token

      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 5
    end

    it 'returns orders with timestamp filter' do
      api_get '/api/v2/market/orders', params: { time_from: 7.hours.ago.to_i, time_to: 5.hours.ago.to_i }, token: token

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result.size).to eq 1
    end

    it 'returns orders with timestamp filter' do
      api_get '/api/v2/market/orders', params: { time_from: 3.hours.ago.to_i }, token: token

      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 2
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get '/api/v2/market/orders', params: { time_from: 3.hours.ago.to_i }, token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/market/orders', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('market.trade.not_permitted')
    end
  end

  describe 'GET /api/v2/market/orders/:id' do
    let(:order)  { create(:order_bid, :btcusd, price: '12.32'.to_d, volume: '3.14', origin_volume: '12.13', member: member, trades_count: 1) }
    let!(:trade) { create(:trade, :btcusd, taker_order: order) }

    it 'should get specified order by id' do
      api_get "/api/v2/market/orders/#{order.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['id']).to eq order.id
      expect(result['executed_volume']).to eq '8.99'
    end

    it 'should get specified order by uuid' do
      api_get "/api/v2/market/orders/#{order.uuid}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['uuid']).to eq order.uuid
      expect(result['executed_volume']).to eq '8.99'
    end

    it 'should include related trades' do
      api_get "/api/v2/market/orders/#{order.id}", token: token

      result = JSON.parse(response.body)
      expect(result['trades_count']).to eq 1
      expect(result['trades'].size).to eq 1
      expect(result['trades'].first['id']).to eq trade.id
      expect(result['trades'].first['side']).to eq 'buy'
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get "/api/v2/market/orders/#{order.id}", token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    it 'should get 404 error when order doesn\'t exist' do
        api_get '/api/v2/market/orders/1234', token: token
        expect(response.code).to eq '404'
        expect(response).to include_api_error('record.not_found')
    end

    it 'should raise error' do
      api_get '/api/v2/market/orders/1234asd', token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invaild_id_or_uuid')
    end
  end

  describe 'POST /api/v2/market/orders' do
    it 'creates a sell order on peatio engine' do
      member.get_account(:btc).update_attributes(balance: 100)

      expect do
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', price: '2014' }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['id']).to eq OrderAsk.last.id
      end.to change(OrderAsk, :count).by(1)
    end

    it 'submit a sell order on third party engine' do
      member.get_account(:btc).update_attributes(balance: 100)
      Market.find('btcusd').engine.update(driver: "finex-spot")
      AMQP::Queue.expects(:publish)

      expect do
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', price: '2014' }
        expect(response).to be_successful
        expect(response_body['market']).to eq 'btcusd'
      end.not_to change(OrderAsk, :count)
    end

    it 'creates a buy order' do
      member.get_account(:usd).update_attributes(balance: 100_000)
      AMQP::Queue.expects(:enqueue).with(:order_processor, is_a(Hash), is_a(Hash))

      expect do
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '12.13', price: '2014' }
        expect(response).to be_successful
        expect(JSON.parse(response.body)['id']).to eq OrderBid.last.id
      end.to change(OrderBid, :count).by(1)
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '12.13', price: '2014' }
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    it 'validates missing params' do
      member.get_account(:usd).update_attributes(balance: 100_000)
      api_post '/api/v2/market/orders', token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('market.order.missing_market')
      expect(response).to include_api_error('market.order.missing_side')
      expect(response).to include_api_error('market.order.missing_volume')
      expect(response).to include_api_error('market.order.missing_price')
    end

    it 'validates volume positiveness' do
      old_count = OrderAsk.count
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '-1.1', price: '2014' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.non_positive_volume')
      expect(OrderAsk.count).to eq old_count
    end

    it 'validates volume to be a number' do
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: 'test', price: '2014' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.non_decimal_volume')
    end

    it 'validates volume greater than min_amount' do
      member.get_account(:btc).update_attributes(balance: 1)
      m = Market.find(:btcusd)
      m.update(min_amount: 1.0)
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '0.1', price: '2014' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_volume_or_price')
    end

    it 'validates price less than max_price' do
      member.get_account(:usd).update_attributes(balance: 1)
      m = Market.find(:btcusd)
      m.update(max_price: 1.0)
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.1', price: '2' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_volume_or_price')
    end

    it 'validates volume precision' do
      member.get_account(:usd).update_attributes(balance: 1)
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.123456789', price: '0.1' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_volume_or_price')
    end

    it 'validates price greater than min_price' do
      member.get_account(:usd).update_attributes(balance: 1)
      m = Market.find(:btcusd)
      m.update(min_price: 1.0)
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.1', price: '0.2' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_volume_or_price')
    end

    it 'validates price precision' do
      member.get_account(:usd).update_attributes(balance: 1)
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.12', price: '0.123' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.invalid_volume_or_price')
    end

    it 'validates enough funds' do
      old_count = OrderAsk.count
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', price: '2014' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.account.insufficient_balance')
      expect(OrderAsk.count).to eq old_count
    end

    it 'validates price positiveness' do
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', price: '-1.1' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.non_positive_price')
    end

    it 'validates price to be a number' do
      api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', price: 'test' }
      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.order.non_decimal_price')
    end

    context 'market order' do
      it 'validates that market has sufficient volume' do
        member.get_account(:btc).update_attributes(balance: 20)
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '12.13', ord_type: 'market' }
        expect(response.code).to eq '422'
        expect(response).to include_api_error('market.order.insufficient_market_liquidity')
      end

      it 'validates that order has no price param' do
        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '0.5', price: '0.5', ord_type: 'market' }
        expect(response.code).to eq '422'
        expect(response).to include_api_error('market.order.market_order_price')
      end

      it 'creates sell order' do
        create(:order_bid, :btcusd, price: '10'.to_d, volume: '10', origin_volume: '10', member: member)

        member.get_account(:btc).update_attributes(balance: 1)

        expect do
          api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '0.5', ord_type: 'market' }
        end.to change(OrderAsk, :count).by(1)

        expect(response).to be_successful
        expect(JSON.parse(response.body)['id']).to eq OrderAsk.last.id
      end

      context 'submit sell order on third party engine' do
        it do
          create(:order_bid, :btcusd, price: '10'.to_d, volume: '10', origin_volume: '10', member: member)

          member.get_account(:btc).update_attributes(balance: 1)

          Market.find('btcusd').engine.update(driver: "finex-spot")

          AMQP::Queue.expects(:publish)

          expect do
            api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'sell', volume: '0.5', ord_type: 'market' }
          end.not_to change(OrderAsk, :count)

          expect(response).to be_successful
        end
      end

      it 'creates buy order' do
        create(:order_ask, :btcusd, price: '10'.to_d, volume: '10', origin_volume: '10', member: member)

        member.get_account(:usd).update_attributes(balance: 10)

        api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.5', ord_type: 'market' }

        expect do
          api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.5', ord_type: 'market' }
        end.to change(OrderBid, :count).by(1)

        expect(response).to be_successful
        expect(JSON.parse(response.body)['id']).to eq OrderBid.last.id
      end

      context '#compute_locked' do
        before do
          create(:order_ask, :btcusd, price: '10'.to_d, volume: '10', origin_volume: '10', member: member)
          member.get_account(:usd).update_attributes(balance: 10)
        end

        it 'locks all balance' do
          api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '1', ord_type: 'market' }

          expect(Order.find(response_body['id']).locked).to eq member.get_account(:usd).balance
        end

        it 'locks with locking_buffer' do
          api_post '/api/v2/market/orders', token: token, params: { market: 'btcusd', side: 'buy', volume: '0.5', ord_type: 'market' }

          # Price: 10, volume: 0.5, locking_buffer: 1.1
          expect(Order.find(response_body['id']).locked).to eq 5.5
        end
      end
    end
  end

  describe 'POST /api/v2/market/orders/:id/cancel' do
    let!(:order) { create(:order_bid, :btcusd, price: '12.32'.to_d, volume: '3.14', origin_volume: '12.13', locked: '20.1082', origin_locked: '38.0882', member: member) }

    context 'succesful' do
      before do
        member.get_account(:usd).update_attributes(locked: order.price * order.volume)
      end

      it 'should cancel specified order by id' do
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)

        expect do
          api_post "/api/v2/market/orders/#{order.id}/cancel", token: token
          expect(response).to be_successful
          expect(JSON.parse(response.body)['id']).to eq order.id
        end.not_to change(Order, :count)
      end

      it 'should cancel specified order by uuid' do
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)

        expect do
          api_post "/api/v2/market/orders/#{order.uuid}/cancel", token: token
          expect(response).to be_successful
          expect(JSON.parse(response.body)['uuid']).to eq order.uuid
        end.not_to change(Order, :count)
      end
    end

    context 'third party order' do
      before do
        order.market.engine.update(driver: "finex-spot")
      end

      it 'should cancel specified order by uuid' do
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes).never
        AMQP::Queue.expects(:publish).with(order.market.engine.driver, data: order.as_json_for_third_party, type: 3)

        expect do
          api_post "/api/v2/market/orders/#{order.uuid}/cancel", token: token
          expect(response).to be_successful
          expect(JSON.parse(response.body)['uuid']).to eq order.uuid
        end.not_to change(Order, :count)
      end
    end

    context 'failed' do
      it 'should return order not found error' do
        api_post '/api/v2/market/orders/0/cancel', token: token
        expect(response.code).to eq '404'
        expect(response).to include_api_error('record.not_found')
      end

      context 'unauthorized' do
        before do
          Ability.stubs(:user_permissions).returns([])
        end

        it 'renders unauthorized error' do
          api_post "/api/v2/market/orders/#{order.uuid}/cancel", token: token
          expect(response).to have_http_status 403
          expect(response).to include_api_error('user.ability.not_permitted')
        end
      end
    end
  end

  describe 'POST /api/v2/market/orders/cancel' do
    before do
      create(:order_ask, :btcusd, price: '12.32', volume: '3.14', origin_volume: '12.13', member: member)
      create(:order_bid, :btcusd, price: '12.32', volume: '3.14', origin_volume: '12.13', member: member)
      create(:order_bid, :btceth, price: '12.32', volume: '3.14', origin_volume: '12.13', member: member)

      member.get_account(:btc).update_attributes(locked: '5')
      member.get_account(:usd).update_attributes(locked: '50')
    end

    it 'should cancel all my orders' do
      member.orders.each do |o|
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: o.to_matching_attributes)

      end

      expect do
        api_post '/api/v2/market/orders/cancel', token: token
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result.size).to eq 3
      end.not_to change(Order, :count)
    end

    context 'third party order' do

      before do
        Market.find('btcusd').engine.update(driver: "finex-spot")
        Market.find('btceth').engine.update(driver: "finex-spot")
      end

      it 'should cancel all my orders on market with third party engine' do
        AMQP::Queue.expects(:enqueue).never

        member.orders.each do |o|
          AMQP::Queue.expects(:publish).with(o.market.engine.driver, data: o.as_json_for_third_party, type: 3)
        end

        expect do
          api_post '/api/v2/market/orders/cancel', token: token
          expect(response).to be_successful

          result = JSON.parse(response.body)
          expect(result.size).to eq 3
        end.not_to change(Order, :count)
      end
    end

    it 'should cancel all my orders for specific market' do
      member.orders.where(market: 'btceth').each do |o|
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: o.to_matching_attributes)
      end

      expect do
        api_post '/api/v2/market/orders/cancel', token: token, params: { market: 'btceth' }
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result.size).to eq 1
      end.not_to change(Order, :count)
    end

    it 'should cancel all my asks' do
      member.orders.where(type: 'OrderAsk').each do |o|
        AMQP::Queue.expects(:enqueue).with(:matching, action: 'cancel', order: o.to_matching_attributes)
      end

      expect do
        api_post '/api/v2/market/orders/cancel', token: token, params: { side: 'sell' }
        expect(response).to be_successful

        result = JSON.parse(response.body)
        expect(result.size).to eq 1
        expect(result.first['id']).to eq member.orders.where(type: 'OrderAsk').first.id
      end.not_to change(Order, :count)
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_post '/api/v2/market/orders/cancel', token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end
end
