describe APIv2::Withdraws, type: :request do
  let(:member) { create(:member, :verified_identity) }
  let(:token) { jwt_for(member) }
  let(:unverified_member) { create(:member, :unverified) }
  let(:unverified_member_token) { jwt_for(unverified_member) }
  let(:btc_withdraws) { create_list(:btc_withdraw, 20, member: member) }
  let(:usd_withdraws) { create_list(:usd_withdraw, 20, member: member) }

  before do
    # Force evaluate all.
    btc_withdraws
    usd_withdraws
  end

  describe 'GET /api/v2/withdraws' do
    it 'should require authentication' do
      get '/api/v2/withdraws'
      expect(response.code).to eq '401'
    end

    it 'should validate currency param' do
      api_get '/api/v2/withdraws', params: { currency: 'FOO' }, token: token
      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
    end

    it 'should validate page param' do
      api_get '/api/v2/withdraws', params: { page: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"page page must be greater than zero."}}'
    end

    it 'should validate limit param' do
      api_get '/api/v2/withdraws', params: { limit: 9999 }, token: token
      expect(response.code).to eq '422'
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
      api_post '/api/v2/withdraws', params: { currency: 'btc', rid: Faker::Bitcoin.address, amount: 'invalid' }, token: token
      expect(response.code).to eq '422'
    end

    it 'should validate currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'invalid', rid: Faker::Bitcoin.address, amount: '1' }, token: token
      expect(response.code).to eq '422'
    end

    it 'should create withdraw using downcase currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'btc', rid: Faker::Bitcoin.address, amount: '1' }, token: token
      expect(response.code).to eq '201'
    end

    it 'should create withdraw using upcase currency code' do
      api_post '/api/v2/withdraws', params: { currency: 'BTC', rid: Faker::Bitcoin.address, amount: '1' }, token: token
      expect(response.code).to eq '201'
    end

    it 'should allow to create withdraw where amount is fraction number' do
      api_post '/api/v2/withdraws', params: { currency: 'BTC', rid: Faker::Bitcoin.address, amount: '0.1' }, token: token
      expect(response.code).to eq '201'
      expect(JSON.parse(response.body)['amount'].to_d).to eq '0.1'.to_d
    end

    it 'sets status to «submitted» after creation' do
      api_post '/api/v2/withdraws', params: { currency: 'btc', rid: Faker::Bitcoin.address, amount: '1' }, token: token
      expect(response.code).to eq '201'
      withdraw = Withdraw.find_by_id(JSON.parse(response.body)['id'])
      expect(withdraw.aasm_state).to eq 'submitted'
    end
  end
end
