# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Members, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:token) { jwt_for(member) }

  describe 'GET /members/me' do
    it 'should return current user profile with accounts info' do
      api_get '/api/v2/members/me', token: token
      expect(response).to be_success
      result = JSON.parse(response.body)
      expect(result['sn']).to eq member.sn
      expect(result['accounts']).to match [
        { 'currency' => 'bch', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'btc', 'balance' => '12.13', 'locked' => '3.14' },
        { 'currency' => 'dash', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'eth', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'ltc', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'trst', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'usd', 'balance' => '2014.47', 'locked' => '0.0' },
        { 'currency' => 'xrp', 'balance' => '0.0', 'locked' => '0.0' }
      ]
    end
  end
end
