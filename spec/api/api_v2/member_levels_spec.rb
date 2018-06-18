# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::MemberLevels, type: :request do
  describe 'GET /member_levels' do
    it 'responds with 200 and returns correct data' do
      api_get '/api/v2/member_levels'
      expect(response).to be_success
      expect(response.body).to eq '{"deposit":{"minimum_level":3},"withdraw":{"minimum_level":3},"trading":{"minimum_level":3}}'
    end
  end
end
