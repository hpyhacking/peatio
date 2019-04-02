# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Public::MemberLevels, type: :request do
  describe 'GET /member_levels' do
    it 'responds with 200 and returns correct data' do
      api_get '/api/v2/public/member-levels'
      expect(response).to be_successful
      expect(response.body).to eq '{"deposit":{"minimum_level":3},"withdraw":{"minimum_level":3},"trading":{"minimum_level":3}}'
    end
  end
end
