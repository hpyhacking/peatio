# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    class Mount
      get('/null') { '' }
      get('/broken') { raise Error, code: 2_014_310, text: 'MtGox bankrupt' }
    end
  end
end

describe API::V2::Mount, type: :request do
  let(:middlewares) { API::V2::Mount.middleware }
  it 'should use auth and attack middleware' do
    expect(middlewares.drop(1)).to eq [[:use, API::V2::Auth::Middleware], [:use, Rack::Attack]]
  end

  context 'handle exception on request processing' do
    it 'should render json error message' do
      get '/api/v2/broken'
      expect(response.code).to eq '400'
      expect(JSON.parse(response.body)).to eq('error' => { 'code' => 2_014_310, 'message' => 'MtGox bankrupt' })
    end
  end

  context 'handle exception on request routing' do
    it 'should render json error message' do
      get '/api/v2/non/exist'
      expect(response.code).to eq '404'
    end
  end
end
