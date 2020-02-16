# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    class Mount
      # Use /public namespace for skipping rack-jwt authorization.
      namespace :public do
        get('/null') { '' }
        get('/record-not-found') { raise ActiveRecord::RecordNotFound }
        get('/auth-error') { raise Peatio::Auth::Error }
        get('/standard-error') { raise StandardError }
      end
    end
  end
end

describe API::V2::Mount, type: :request do
  let(:middlewares) { API::V2::Mount.middleware }
  it 'should use attack middleware' do
    expect(middlewares.drop(1)).to eq [[:use, Rack::Attack]]
  end

  context 'handle exception on request processing' do
    it 'returns array with record.not_found error' do
      get '/api/v2/public/record-not-found'
      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'returns array with jwt.decode_and_verify error' do
      get '/api/v2/public/auth-error'
      expect(response.code).to eq '401'
      expect(response).to include_api_error('jwt.decode_and_verify')
    end

    it 'returns array with server.internal_error error' do
      get '/api/v2/public/standard-error'
      expect(response.code).to eq '500'
      expect(response).to include_api_error('server.internal_error')
    end
  end

  context 'handle exception on request routing' do
    it 'should render json error message' do
      get '/api/v2/public/non/exist'
      expect(response.code).to eq '404'
    end
  end
end
