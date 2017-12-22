describe APIv2::Members, type: :request do
  let(:member) do
    create(:verified_member).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:token) { create(:api_token, member: member) }

  describe 'GET /members/me' do
    before { Currency.stubs(:codes).returns(%w[usd btc]) }

    it 'should return current user profile with accounts info' do
      signed_get '/api/v2/members/me', token: token
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result['sn']).to eq member.sn
      expect(result['activated']).to be true
      expect(result['accounts']).to match [
        { 'currency' => 'usd', 'balance' => '2014.47', 'locked' => '0.0' },
        { 'currency' => 'btc', 'balance' => '12.13', 'locked' => '3.14' }
      ]
    end
  end
end
