# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class AuthTest < Grape::API
    get('/auth_test') do
      authenticate!
      current_user
    end
  end

  class Mount
    mount AuthTest
  end
end

describe APIv2::Helpers, type: :request do
  context '#authentic?' do
    let!(:member) { create(:member, :level_3) }
    let!(:token) { jwt_for(member) }

    context 'Authenticate using headers' do
      it 'should response successfully' do
        api_get '/api/v2/auth_test', foo: 'bar', hello: 'world', token: token
        expect(response).to be_success
      end

      it 'should set current user' do
        api_get '/api/v2/auth_test', foo: 'bar', hello: 'world', token: token
        expect(response.body).to eq member.reload.to_json
      end

      it 'should fail authorization' do
        get '/api/v2/auth_test'

        expect(response.code).to eq '401'
        expect(response.body).to eq '{"error":{"code":2001,"message":"2001: Authorization failed"}}'
      end
    end
  end
end
