describe APIv2::Withdraws, type: :request do
  let(:member) { create(:member, :verified_identity) }
  let(:token) { jwt_for(member) }

  let(:unverified_member) { create(:member, :unverified) }
  let(:unverified_member_token) { jwt_for(unverified_member) }

  let(:btc_withdraws) { btc_withdraw_addresses.map { |address| create(:satoshi_withdraw, member: member, fund_source_id: address.id) } }
  let(:usd_withdraws) { usd_withdraw_addresses.map { |address| create(:bank_withdraw, member: member, fund_source_id: address.id) } }
  let(:btc_withdraw_addresses) { create_list(:btc_fund_source, 20, member: member) }
  let(:usd_withdraw_addresses) { create_list(:usd_fund_source, 20, member: member) }

  before do
    # Force evaluate all.
    btc_withdraws
    usd_withdraws
    btc_withdraw_addresses
    usd_withdraw_addresses
  end

  describe 'GET /api/v2/withdraws' do
    it 'should require authentication' do
      get '/api/v2/withdraws'
      expect(response.code).to eq '401'
    end

    it 'should validate currency param' do
      api_get '/api/v2/withdraws', params: { currency: 'FOO' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
    end

    it 'should validate page param' do
      api_get '/api/v2/withdraws', params: { page: -1 }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"page page must be greater than zero."}}'
    end

    it 'should validate limit param' do
      api_get '/api/v2/withdraws', params: { limit: 9999 }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000."}}'
    end

    it 'should return withdraws for all currencies by default' do
      api_get '/api/v2/withdraws', params: { limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc usd ]
    end

    it 'should return withdraws specified currency' do
      api_get '/api/v2/withdraws', params: { currency: 'BTC', limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc ]
    end

    it 'should paginate withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/withdraws', params: { currency: 'BTC', limit: 10, page: 1 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraws[0].id

      api_get '/api/v2/withdraws', params: { currency: 'BTC', limit: 10, page: 2 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraws[10].id
    end

    it 'should sort withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/withdraws', params: { currency: 'BTC', limit: 100 }, token: token
      expect(response).to be_success
      results = JSON.parse(response.body)
      expect(results.map { |x| x['id'] }).to eq ordered_withdraws.map(&:id)
    end
  end

  describe 'POST /api/v2/withdraws' do
    it 'should validate withdraw amount' do
      api_post '/api/v2/withdraws', params: { currency: 'btc', address_id: btc_withdraw_addresses.first.id, amount: 'invalid' }, token: token
      expect(response.code).to eq '400'
    end

    it 'should validate currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'invalid', address_id: btc_withdraw_addresses.first.id, amount: '1' }, token: token
      expect(response.code).to eq '400'
    end

    it 'should create withdraw using downcase currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'btc', address_id: btc_withdraw_addresses.first.id, amount: '1' }, token: token
      expect(response.code).to eq '201'
    end

    it 'should create withdraw using upcase currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'BTC', address_id: btc_withdraw_addresses.first.id, amount: '1' }, token: token
      expect(response.code).to eq '201'
    end

    it 'should allow to create withdraw where amount is fraction number' do
      api_post '/api/v2/withdraws', params: { currency: 'BTC', address_id: btc_withdraw_addresses.first.id, amount: '0.1' }, token: token
      expect(response.code).to eq '201'
      expect(JSON.parse(response.body)['amount'].to_d).to eq '0.1'.to_d
    end
  end

  describe 'GET /api/v2/withdraws/addresses' do
    it 'should require authentication' do
      get '/api/v2/withdraws/addresses'
      expect(response.code).to eq '401'
    end

    it 'should validate currency param' do
      api_get '/api/v2/withdraws/addresses', params: { currency: 'FOO' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
    end

    it 'should validate page param' do
      api_get '/api/v2/withdraws/addresses', params: { page: -1 }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"page page must be greater than zero."}}'
    end

    it 'should validate limit param' do
      api_get '/api/v2/withdraws/addresses', params: { limit: 9999 }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000."}}'
    end

    it 'should return withdraw addresses for all currencies by default' do
      api_get '/api/v2/withdraws/addresses', params: { limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc usd ]
    end

    it 'should return withdraw addresses for specified currency' do
      api_get '/api/v2/withdraws/addresses', params: { currency: 'BTC', limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc ]
    end

    it 'should paginate withdraws' do
      ordered_withdraw_addresses = btc_withdraw_addresses.sort_by(&:id).reverse

      api_get '/api/v2/withdraws/addresses', params: { currency: 'BTC', limit: 10, page: 1 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraw_addresses[0].id

      api_get '/api/v2/withdraws/addresses', params: { currency: 'BTC', limit: 10, page: 2 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraw_addresses[10].id
    end

    it 'should sort withdraws' do
      ordered_withdraw_addresses = btc_withdraw_addresses.sort_by(&:id).reverse

      api_get '/api/v2/withdraws/addresses', params: { currency: 'BTC', limit: 100 }, token: token
      expect(response).to be_success
      results = JSON.parse(response.body)
      expect(results.map { |x| x['id'] }).to eq ordered_withdraw_addresses.map(&:id)
    end

    it 'should return correct label and address' do
      ordered_withdraw_addresses = btc_withdraw_addresses.sort_by(&:id).reverse

      api_get '/api/v2/withdraws/addresses', params: { currency: 'BTC', limit: 100 }, token: token
      expect(response).to be_success

      results = JSON.parse(response.body)
      expect(results.map { |x| x['label'] }).to eq ordered_withdraw_addresses.map(&:extra)
      expect(results.map { |x| x['address'] }).to eq ordered_withdraw_addresses.map(&:uid)
    end
  end

  describe 'POST /api/v2/withdraws/addresses' do
    it 'should require currency code' do
      api_post '/api/v2/withdraws/addresses', params: { label: 'valid', address: '123456' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency is missing, currency does not have a valid value"}}'
    end

    it 'should require label' do
      api_post '/api/v2/withdraws/addresses', params: { currency: 'btc', address: '123456' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"label is missing"}}'
    end

    it 'should require address' do
      api_post '/api/v2/withdraws/addresses', params: { currency: 'btc', label: 'valid' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"address is missing"}}'
    end

    it 'should validate currency code' do
      api_post '/api/v2/withdraws/addresses', params: { currency: 'invalid', label: 'valid', address: '123456' }, token: token
      expect(response.code).to eq '400'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
    end

    it 'should create withdraw address' do
      api_post '/api/v2/withdraws/addresses', params: { label: 'btc address', currency: 'btc', address: '123456' }, token: token
      expect(response.code).to eq '201'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/deposits', token: unverified_member_token
      expect(response.code).to eq '401'
    end
  end
end
