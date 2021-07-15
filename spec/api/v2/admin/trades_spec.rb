# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Trades, type: :request do
  let(:uid) { 'ID00FEE1DEAD' }
  let(:email) { 'someone@mailbox.com' }
  let(:admin) { create(:member, :admin, :level_3, email: email, uid: uid) }
  let(:token) { jwt_for(admin) }
  let(:member) { create(:member, :level_3) }
  let(:member_token) { jwt_for(member) }

  describe 'GET /api/v2/admin/trades' do
    let!(:trades) do
      [
        create(:trade, :btcusd, price: 12.0, amount: 2.0, created_at: 3.days.ago),
        create(:trade, :btcusd, price: 3.0, amount: 13.0, created_at: 5.days.ago),
        create(:trade, :btcusd, price: 25.0, amount: 5.0, created_at: 1.days.ago, maker: member),
        create(:trade, :btcusd, price: 6.0, amount: 5.0, created_at: 5.days.ago, taker: member),
        create(:trade, :btcusd, price: 5.0, amount: 6.0, created_at: 5.days.ago, taker: member),
        create(:trade, :btceth, price: 5.0, amount: 6.0, created_at: 5.days.ago, taker: member),
        create(:trade, :btceth_qe, price: 5.0, amount: 6.0, created_at: 5.days.ago, taker: member),
      ]
    end

    it 'entity provides correct fields' do
      api_get'/api/v2/admin/trades', token: token, params: { limit: 5 }
      result = JSON.parse(response.body).first
      keys = %w[id amount price total maker_order_email taker_order_email created_at maker_uid taker_uid
        taker_type market market_type maker_fee_currency maker_fee_amount taker_fee_currency taker_fee_amount]

      expect(result.keys).to match_array keys
      expect(result.values).not_to include nil
    end

    it 'csv export' do
      api_get'/api/v2/admin/trades', token: token, params: { format: :csv }
      expect(response).to be_successful
    end

    context 'authentication' do
      it 'requires token' do
        get '/api/v2/admin/trades'
        expect(response.code).to eq '401'
      end

      it 'validates permissions' do
        api_get'/api/v2/admin/trades', token: member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'authenticate admin' do
        api_get'/api/v2/admin/trades', token: token
        expect(response).to be_successful
      end
    end

    context 'pagination' do
      it 'with default values' do
        api_get'/api/v2/admin/trades', token: token
        result = JSON.parse(response.body)

        expect(result.length).to eq trades.length - ::Trade.qe.count
      end

      it 'validates limit' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 'meow' }
        expect(response).to include_api_error 'admin.pagination.non_integer_limit'
      end

      it 'validates page' do
        api_get'/api/v2/admin/trades', token: token, params: { page: 'meow' }
        expect(response).to include_api_error 'admin.pagination.non_integer_page'
      end

      it 'first 5 trades ordered by id' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 5 }
        result = JSON.parse(response.body)
        expected = trades[1...6]

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end

      it 'second 5 trades ordered by id' do
        api_get'/api/v2/admin/trades', token: token, params: { limit: 5, page: 2 }
        result = JSON.parse(response.body)
        expected = trades[0...1]
        expected.select! {|trade| trade.market_type == 'spot'}

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'ordering' do
      it 'validates ordering' do
        api_get'/api/v2/admin/trades', token: token, params: { ordering: 'straight' }

        expect(response).not_to be_successful
      end

      it 'orders by price ascending' do
        api_get'/api/v2/admin/trades', token: token, params: { order_by: 'price', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = trades.sort { |a, b| a.price <=> b.price }
        expected.select! {|trade| trade.market_type == 'spot'}

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end

      it 'orders by amount descending' do
        api_get'/api/v2/admin/trades', token: token, params: { order_by: 'amount', ordering: 'asc' }
        result = JSON.parse(response.body)
        expected = trades.sort { |a, b| b.amount <=> a.amount }
        expected.select! {|trade| trade.market_type == 'spot'}

        expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'filtering' do
      context 'with market' do
        it 'validates market param' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btcbtc' }
          expect(response).to include_api_error "admin.market.doesnt_exist"
        end

        it 'filters by spot market' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btcusd' }
          result = JSON.parse(response.body)

          expected = trades.select { |t| t.market_id == 'btcusd' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'filters by spot market' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btceth' }
          result = JSON.parse(response.body)

          expected = trades.select { |t| t.market_id == 'btceth' && t.market_type == 'spot' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
          expect(result.map { |t| t['market_type'] }).to match_array expected.map(&:market_type)
        end

        it 'filters by qe market' do
          api_get'/api/v2/admin/trades', token: token, params: { market: 'btceth', market_type: 'qe' }
          result = JSON.parse(response.body)

          expected = trades.select { |t| t.market_id == 'btceth' && t.market_type == 'qe' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
          expect(result.map { |t| t['market_type'] }).to match_array expected.map(&:market_type)
        end
      end

      context 'with uid' do
        it 'returns spot trades for specific user (both maker and taker sides)' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: member.uid }
          result = JSON.parse(response.body)
          expected = member.trades.where(market_type: 'spot')

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'returns qe trades for specific user (both maker and taker sides)' do
          api_get'/api/v2/admin/trades', token: token, params: { market_type: 'qe', uid: member.uid }
          result = JSON.parse(response.body)
          expected = member.trades.where(market_type: 'qe')

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'return error when user does not exist' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: 'ID00DEADBEEF' }
          expect(response).to include_api_error 'admin.user.doesnt_exist'
        end

        it 'empty collection when user has no trades' do
          api_get'/api/v2/admin/trades', token: token, params: { uid: admin.uid }
          expect(JSON.parse(response.body)).to be_empty
        end
      end

      context 'with timestamps' do
        it 'validates created_at_from' do
          api_get'/api/v2/admin/trades', token: token, params: { from: 'yesterday' }
          expect(response).to include_api_error 'admin.filter.range_from_invalid'
        end

        it 'validates created_at_to' do
          api_get'/api/v2/admin/trades', token: token, params: { to: 'today' }
          expect(response).to include_api_error 'admin.filter.range_to_invalid'
        end

        it 'returns trades created after specidfied date' do
          api_get'/api/v2/admin/trades', token: token, params: { from: 4.days.ago }

          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at >= 4.days.ago && t.market_type == 'spot' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'return trades created before specidfied date' do
          api_get'/api/v2/admin/trades', token: token, params: { to: 2.days.ago }

          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at < 2.days.ago && t.market_type == 'spot' }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end

        it 'returns trades created after and before specidfied dates' do
          api_get'/api/v2/admin/trades', token: token, params: { from: 4.days.ago, to: 2.days.ago }
          result = JSON.parse(response.body)
          expected = trades.select { |t| t.created_at >= 4.days.ago && t.created_at < 2.days.ago }

          expect(result.map { |t| t['id'] }).to match_array expected.map(&:id)
        end
      end
    end
  end

  describe 'GET /api/v2/admin/trades/:id' do
    let(:maker) { create(:order_ask, :btcusd) }
    let(:taker) { create(:order_bid, :btcusd) }
    let(:trade) { create(:trade, :btcusd, price: 12.0, amount: 2.0, maker_order: maker, taker_order: taker) }

    it 'entity provides correct fields' do
      api_get "/api/v2/admin/trades/#{trade.id}", token: token
      result = JSON.parse(response.body)
      keys = %w[id amount price total maker_order_email taker_order_email created_at maker_uid taker_uid taker_type
        market market_type maker_fee_currency maker_fee maker_fee_amount taker_fee_currency taker_fee taker_fee_amount maker_order taker_order]

      expect(result.keys).to match_array keys
      expect(result.values).not_to include nil
    end

    it 'exposes correct orders' do
      api_get "/api/v2/admin/trades/#{trade.id}", token: token
      result = JSON.parse(response.body)

      expect(result['maker_order']['id']).to eq maker.id
      expect(result['taker_order']['id']).to eq taker.id
    end

    it 'fee calculation' do
      api_get "/api/v2/admin/trades/#{trade.id}", token: token
      result = JSON.parse(response.body)

      expect(result['maker_fee_amount']).to eq((trade.total * maker.maker_fee).to_s)
      expect(result['taker_fee_amount']).to eq((trade.amount * taker.taker_fee).to_s)
    end

    it 'fee currency' do
      api_get "/api/v2/admin/trades/#{trade.id}", token: token
      result = JSON.parse(response.body)

      expect(result['maker_fee_currency']).to eq 'usd'
      expect(result['taker_fee_currency']).to eq 'btc'
    end
  end
end
