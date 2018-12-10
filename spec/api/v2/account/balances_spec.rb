# frozen_string_literal: true

describe API::V2::Account::Balances, type: :request do

  let(:member) { create(:member, :level_3) }
  let(:deposit_btc) { create(:deposit, :deposit_btc, member: member, amount: 10) }
  let(:deposit_eth) { create(:deposit, :deposit_eth, member: member, amount: 30.5) }
  let(:withdraw) { create(:new_btc_withdraw, member: member, sum: 5) }
  let(:token) { jwt_for(member) }

  let(:response_body) { { 'currency' => 'eth', 'balance' => '30.5', 'locked' => '0.0' } }

  before do
    deposit_btc.accept!
    deposit_eth.accept!
    withdraw.submit! && withdraw.accept!
  end

  describe 'GET api/v2/account/balances' do

    before { api_get '/api/v2/account/balances', token: token }

    it { expect(response).to have_http_status 200 }

    it 'returns current user balances' do
      result = JSON.parse(response.body)
      expect(result).to match [
        { 'currency' => 'bch', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'btc', 'balance' => '5.0', 'locked' => '5.0' },
        { 'currency' => 'dash', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'eth', 'balance' => '30.5', 'locked' => '0.0' },
        { 'currency' => 'ltc', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'trst', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'usd', 'balance' => '0.0', 'locked' => '0.0' },
        { 'currency' => 'xrp', 'balance' => '0.0', 'locked' => '0.0' }
      ]
    end

    context 'disable currency' do

      before do
        Currency.find('xrp').update(enabled: false) 
        api_get '/api/v2/account/balances', token: token
      end

      it 'returns only balances of enabled currencies' do
        result = JSON.parse(response.body)
        expect(result.count).to eq Currency.enabled.count
      end

    end
  end

  describe 'GET api/v2/account/balances/:currency' do

    before { api_get '/api/v2/account/balances/eth', token: token }

    it { expect(response).to have_http_status 200 }

    it 'returns current user balance by currency' do
      result = JSON.parse(response.body)
      expect(result).to match response_body
    end


    context 'disable currency' do

      before do
        Currency.find('eth').update(enabled: false) 
        api_get '/api/v2/account/balances/eth', token: token
      end

      it { expect(response).to have_http_status 422 }

    end
  end
end
