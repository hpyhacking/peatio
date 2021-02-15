# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Market::Trades, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['Trade']}})
  end

  let(:token) { jwt_for(member) }

  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  let(:btcusd_ask) do
    create(
      :order_ask,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_ask) do
    create(
      :order_ask,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let(:btcusd_bid) do
    create(
      :order_bid,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_bid) do
    create(
      :order_bid,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let(:btcusd_bid_maker) do
    create(
      :order_bid,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_ask_taker) do
    create(
      :order_ask,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let(:btceth_bid_taker) do
    create(
      :order_bid,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let!(:btcusd_ask_trade) { create(:trade, :btcusd, maker_order: btcusd_ask, created_at: 2.days.ago) }
  let!(:btceth_ask_trade) { create(:trade, :btceth, maker_order: btceth_ask, created_at: 2.days.ago) }
  let!(:btcusd_bid_trade) { create(:trade, :btcusd, taker_order: btcusd_bid, created_at: 23.hours.ago) }
  let!(:btceth_bid_trade) { create(:trade, :btceth, taker_order: btceth_bid, taker: member, created_at: 23.hours.ago) }

  describe 'GET /api/v2/market/trades' do
    it 'requires authentication' do
      get '/api/v2/market/trades', params: { market: 'btcusd' }
      expect(response.code).to eq '401'
      expect(response).to include_api_error('jwt.decode_and_verify')
    end

    it 'returns all my recent trades' do
      api_get '/api/v2/market/trades', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result.size).to eq 4

      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['side']).to eq 'sell'
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['order_id']).to eq btcusd_ask.id
      expect(result.find { |t| t['id'] == btceth_ask_trade.id }['side']).to eq 'sell'
      expect(result.find { |t| t['id'] == btceth_ask_trade.id }['order_id']).to eq btceth_ask.id
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['side']).to eq 'buy'
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['order_id']).to eq btcusd_bid.id
      expect(result.find { |t| t['id'] == btceth_bid_trade.id }['side']).to eq 'buy'
      expect(result.find { |t| t['id'] == btceth_bid_trade.id }['order_id']).to eq btceth_bid.id
    end

    it 'returns all my recent trades for btcusd market' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result.size).to eq 2
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['side']).to eq 'sell'
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['order_id']).to eq btcusd_ask.id
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['side']).to eq 'buy'
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['order_id']).to eq btcusd_bid.id
    end

    it 'returns trades for several markets' do
      api_get '/api/v2/market/trades', params: { market: ['btcusd', 'btceth'] }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 4
    end

    it 'returns 1 trade' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
    end

    it 'returns trades for last 24h' do
      create(:trade, :btcusd, maker: member, created_at: 6.hours.ago)
      api_get '/api/v2/market/trades', params: { time_from: 1.day.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 3
    end

    it 'returns trades older than 1 day' do
      api_get '/api/v2/market/trades', params: { time_to: 1.day.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 2
    end

    it 'returns trades for specific hour' do
      create(:trade, :btcusd, maker: member, created_at: 6.hours.ago)
      api_get '/api/v2/market/trades', params: { time_from: 7.hours.ago.to_i, time_to: 5.hours.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
    end

    it 'returns limit out of range error' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1024 }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.trade.invalid_limit')
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('market.trade.not_permitted')
    end

    it 'fee calculation for buy order' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body).find { |t| t['side'] == 'buy' }

      expect(result['order_id']).to eq btcusd_bid.id
      expect(result['fee_amount']).to eq((btcusd_bid.taker_fee * btcusd_bid_trade.amount).to_s)
      expect(result['fee']).to eq btcusd_bid.taker_fee.to_s
    end

    it 'fee calculation for sell order' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body).find { |t| t['side'] == 'sell' }

      expect(result['order_id']).to eq btcusd_ask.id
      expect(result['fee_amount']).to eq((btcusd_ask.taker_fee * btcusd_ask_trade.total).to_s)
      expect(result['fee']).to eq btcusd_ask.taker_fee.to_s
    end

    it 'fee currency for buy order' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body).find { |t| t['side'] == 'buy' }

      expect(result['order_id']).to eq btcusd_bid.id
      expect(result['fee_currency']).to eq 'btc'
    end

    it 'fee currency for sell order' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      result = JSON.parse(response.body).find { |t| t['side'] == 'sell' }

      expect(result['order_id']).to eq btcusd_ask.id
      expect(result['fee_currency']).to eq 'usd'
    end

    context 'type filtering' do
      context 'sell orders' do
        let!(:btceth_ask_trade_taker) { create(:trade, :btceth, taker_order: btceth_ask_taker, created_at: 2.hours.ago) }
        let!(:btcusd_bid_trade_maker) { create(:trade, :btcusd, maker_order: btcusd_bid_maker, created_at: 2.hours.ago) }

        it 'with taker_id = user_id and taker_type = sell' do
          api_get '/api/v2/market/trades', params: { market: 'btceth', type: 'sell' }, token: token
          result = JSON.parse(response.body)

          expect(result.size).to eq 2
          expect(result.find { |t| t['id'] == btceth_ask_trade.id }['side']).to eq 'sell'
          expect(result.find { |t| t['id'] == btceth_ask_trade.id }['order_id']).to eq btceth_ask.id
          expect(result.find { |t| t['id'] == btceth_ask_trade_taker.id }['side']).to eq 'sell'
          expect(result.find { |t| t['id'] == btceth_ask_trade_taker.id }['order_id']).to eq btceth_ask_taker.id
        end

        it 'with maker_id = user_id and taker_type = buy' do
          api_get '/api/v2/market/trades', params: { market: 'btcusd', type: 'sell' }, token: token
          result = JSON.parse(response.body)

          expect(result.size).to eq 2
          expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['side']).to eq 'sell'
          expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['order_id']).to eq btcusd_ask.id
          expect(result.find { |t| t['id'] == btcusd_bid_trade_maker.id }['side']).to eq 'buy'
          expect(result.find { |t| t['id'] == btcusd_bid_trade_maker.id }['order_id']).to eq btcusd_bid_maker.id
        end
      end

      context 'buy orders' do
        let!(:btceth_bid_trade_taker) { create(:trade, :btceth, taker_order: btceth_bid_taker, created_at: 2.hours.ago) }

        it 'with taker_id = user_id and taker_type = buy' do
          api_get '/api/v2/market/trades', params: { market: 'btceth', type: 'buy' }, token: token
          result = JSON.parse(response.body)

          expect(result.size).to eq 2
          expect(result.find { |t| t['id'] == btceth_bid_trade.id }['side']).to eq 'buy'
          expect(result.find { |t| t['id'] == btceth_bid_trade.id }['order_id']).to eq btceth_bid.id
          expect(result.find { |t| t['id'] == btceth_bid_trade_taker.id }['side']).to eq 'buy'
          expect(result.find { |t| t['id'] == btceth_bid_trade_taker.id }['order_id']).to eq btceth_bid_taker.id
        end

        it 'with maker_id = user_id and taker_type = sell' do
          api_get '/api/v2/market/trades', params: { market: 'btcusd', type: 'buy' }, token: token
          result = JSON.parse(response.body)

          expect(result.size).to eq 1
          expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['side']).to eq 'buy'
          expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['order_id']).to eq btcusd_bid.id
        end
      end
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end
end
