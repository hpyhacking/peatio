describe APIv2::Trades, type: :request do
  let(:member) do
    create(:verified_member).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:cny).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:token) { create(:api_token, member: member) }

  let(:ask) do
    create(
      :order_ask,
      currency: 'btccny',
      price: '12.326'.to_d,
      volume: '123.123456789',
      member: member
    )
  end

  let(:bid) do
    create(
      :order_bid,
      currency: 'btccny',
      price: '12.326'.to_d,
      volume: '123.123456789',
      member: member
    )
  end

  let!(:ask_trade) { create(:trade, ask: ask, created_at: 2.days.ago) }
  let!(:bid_trade) { create(:trade, bid: bid, created_at: 1.day.ago) }

  describe 'GET /api/v2/trades' do
    it 'should return all recent trades' do
      get '/api/v2/trades', market: 'btccny'

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 2
    end

    it 'should return 1 trade' do
      get '/api/v2/trades', market: 'btccny', limit: 1

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return trades before timestamp' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get '/api/v2/trades', market: 'btccny', timestamp: 8.hours.ago.to_i, limit: 1
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should return trades between id range' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', market: 'btccny', from: ask_trade.id, to: another.id
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should sort trades in reverse creation order' do
      get '/api/v2/trades', market: 'btccny'

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'should get trades by from and limit' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get '/api/v2/trades', market: 'btccny', from: ask_trade.id, limit: 1, order_by: 'asc'

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end
  end

  describe 'GET /api/v2/trades/my' do
    it 'should require authentication' do
      get '/api/v2/trades/my', market: 'btccny', access_key: 'test', tonce: time_to_milliseconds, signature: 'test'

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2008,"message":"The access key test does not exist."}}'
    end

    it 'should return all my recent trades' do
      signed_get '/api/v2/trades/my', params: { market: 'btccny' }, token: token
      expect(response).to be_success

      result = JSON.parse(response.body)

      expect(result.find { |t| t['id'] == ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == ask_trade.id }['order_id']).to eq ask.id
      expect(result.find { |t| t['id'] == bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == bid_trade.id }['order_id']).to eq bid.id
    end

    it 'should return 1 trade' do
      signed_get '/api/v2/trades/my', params: { market: 'btccny', limit: 1 }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return trades before timestamp' do
      signed_get '/api/v2/trades/my', params: { market: 'btccny', timestamp: 30.hours.ago.to_i }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return limit out of range error' do
      signed_get '/api/v2/trades/my', params: { market: 'btccny', limit: 1024 }, token: token

      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000"}}'
    end
  end
end
