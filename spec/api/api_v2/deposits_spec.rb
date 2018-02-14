describe APIv2::Deposits, type: :request do
  let(:member)       { create(:member, :verified_identity) }
  let(:other_member) { create(:member, :verified_identity) }
  let(:token) { create(:api_token, member: member) }
  let(:unverified_member) { create(:member, :unverified) }
  let(:unverified_member_token) { create(:api_token, member: unverified_member) }

  describe 'GET /api/v2/deposits' do
    before do
      create(:deposit, member: member, currency: 'btc')
      create(:deposit, member: member, currency: 'usd')
      create(:deposit, member: member, currency: 'usd', txid: 1, amount: 520)
      create(:deposit, member: member, currency: 'btc', created_at: 2.day.ago, txid: 'test', amount: 111)
      create(:deposit, member: other_member, currency: 'usd', txid: 10)
    end

    it 'require deposits authentication' do
      get '/api/v2/deposits', token: token
      expect(response.code).to eq '401'
    end

    it 'login deposits' do
      signed_get '/api/v2/deposits', token: token
      expect(response).to be_success
    end

    it 'deposits num' do
      signed_get '/api/v2/deposits', token: token
      expect(JSON.parse(response.body).size).to eq 3
    end

    it 'return limited deposits' do
      signed_get '/api/v2/deposits', params: { limit: 1 }, token: token
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'filter deposits by state' do
      signed_get '/api/v2/deposits', params: { state: 'cancelled' }, token: token
      expect(JSON.parse(response.body).size).to eq 0

      d = create(:deposit, member: member, currency: 'btc')
      d.submit!
      signed_get '/api/v2/deposits', params: { state: 'submitted' }, token: token
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['txid']).to eq d.txid
    end

    it 'deposits currency usd' do
      signed_get '/api/v2/deposits', params: { currency: 'usd' }, token: token
      result = JSON.parse(response.body)
      expect(result.size).to eq 2
      expect(result.all? { |d| d['currency'] == 'usd' }).to be_truthy
    end

    it 'return 404 if txid not exist' do
      signed_get '/api/v2/deposit', params: { txid: 5 }, token: token
      expect(response.code).to eq '404'
    end

    it 'return 404 if txid not belongs_to you ' do
      signed_get '/api/v2/deposit', params: { txid: 10 }, token: token
      expect(response.code).to eq '404'
    end

    it 'ok txid if exist' do
      signed_get '/api/v2/deposit', params: { txid: 1 }, token: token

      expect(response.code).to eq '200'
      expect(JSON.parse(response.body)['amount']).to eq '520.0'
    end

    it 'return deposit no time limit ' do
      signed_get '/api/v2/deposit', params: { txid: 'test' }, token: token

      expect(response.code).to eq '200'
      expect(JSON.parse(response.body)['amount']).to eq '111.0'
    end

    it 'denies access to unverified member' do
      signed_get '/api/v2/deposits', token: unverified_member_token
      expect(response.code).to eq '401'
    end
  end
end
