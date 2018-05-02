describe APIv2::Fees, type: :request do
  describe 'GET /api/v2/fees/withdraw' do
    it 'returns withdraw fees for every visible currency' do
      get '/api/v2/fees/withdraw'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq 6
    end

    it 'returns correct currency withdraw fee' do
      get '/api/v2/fees/withdraw'

      expect(response).to be_success

      result = JSON.parse(response.body)
      currency = result.find { |c| c['currency'] == 'usd' }
      withdraw_fee = Currency.find_by_code(:usd).withdraw_fee.to_s

      expect(currency.dig('currency')).to eq 'usd'
      expect(currency.dig('type')).to eq 'fiat'
      expect(currency.dig('fee', 'value')).to eq withdraw_fee
      expect(currency.dig('fee', 'type')).to eq 'fixed'
    end
  end

  describe 'GET /api/v2/fees/deposit' do
    it 'returns deposit fees for every visible currency' do
      get '/api/v2/fees/deposit'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq 6
    end

    it 'returns correct currency deposit fee' do
      get '/api/v2/fees/deposit'

      expect(response).to be_success

      result = JSON.parse(response.body)
      currency = result.find { |c| c['currency'] == 'usd' }
      deposit_fee = Currency.find_by_code(:usd).deposit_fee.to_s

      expect(currency.dig('currency')).to eq 'usd'
      expect(currency.dig('type')).to eq 'fiat'
      expect(currency.dig('fee', 'value')).to eq deposit_fee
      expect(currency.dig('fee', 'type')).to eq 'fixed'
    end
  end

  describe 'GET /api/v2/fees/trading' do
    it 'returns trading fees' do
      get '/api/v2/fees/trading'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq 1
    end

    it 'returns correct trading fees' do
      get '/api/v2/fees/trading'

      expect(response).to be_success

      result = JSON.parse(response.body)
      market = result.find { |c| c['market'] == 'btcusd' }
      ask_fee = Market.find(:btcusd).ask_fee.to_s
      bid_fee = Market.find(:btcusd).bid_fee.to_s

      expect(market.dig('market')).to eq 'btcusd'
      expect(market.dig('ask_fee', 'type')).to eq 'relative'
      expect(market.dig('ask_fee', 'value')).to eq ask_fee
      expect(market.dig('bid_fee', 'type')).to eq 'relative'
      expect(market.dig('bid_fee', 'value')).to eq bid_fee
    end
  end
end
