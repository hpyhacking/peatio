# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Withdraws, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }
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

    it 'denies access to unverified member' do
      api_get '/api/v2/withdraws', token: level_0_member_token
      expect(response.code).to eq '401'
      expect(JSON.parse(response.body)['error']).to eq( {'code' => 2000, 'message' => 'Please, pass the corresponding verification steps to withdraw funds.'} )
    end
  end
end
