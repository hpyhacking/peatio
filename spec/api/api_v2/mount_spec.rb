# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Mount
    get('/null') { '' }
    get('/broken') { raise Error, code: 2_014_310, text: 'MtGox bankrupt' }
  end
end

describe APIv2::Mount, type: :request do
  let(:middlewares) { APIv2::Mount.middleware }
  it 'should use auth and attack middleware' do
    expect(middlewares.drop(1)).to eq [[:use, APIv2::Auth::Middleware], [:use, Rack::Attack], [:use, APIv2::CORS::Middleware]]
  end

  it 'should allow 3rd party ajax call' do
    ENV['API_CORS_ORIGINS'] = '*'
    get '/api/v2/null'
    expect(response).to be_success
    expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
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
      expect(response.body).to eq '404 Not Found'
    end
  end
end
