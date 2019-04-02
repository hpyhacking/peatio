# encoding: UTF-8
# frozen_string_literal: true

require 'rack/cors'

describe Rack::Cors, type: :request do

  let(:member) { create(:member, :level_3) }
  let(:frontend_url) { 'https://frontend.io' }
  let(:local_url) { 'http://localhost:3000' }
  let(:token) { jwt_for(member) }

  let(:app) {
    Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins CORS::Validations.validate_origins(ENV['API_CORS_ORIGINS'])
          resource '/api/*',
            methods: %i[get post delete put patch options head],
            headers: :any,
            credentials: ENV.true?('API_CORS_ALLOW_CREDENTIALS'),
            max_age: CORS::Validations.validate_max_age(ENV['API_CORS_MAX_AGE'])
        end
      end
      run Peatio::Application
    end
  }

  def check_cors(response, origin, allow_crendentails, max_age = '3600')
    expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, DELETE, PUT, PATCH, OPTIONS, HEAD')
    expect(response.headers['Access-Control-Allow-Credentials']).to eq(allow_crendentails)
    expect(response.headers['Access-Control-Max-Age']).to eq(max_age)
  end

  def without_cors(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq(nil)
    expect(response.headers['Access-Control-Allow-Methods']).to eq(nil)
    expect(response.headers['Access-Control-Allow-Credentials']).to eq(nil)
    expect(response.headers['Access-Control-Max-Age']).to eq(nil)
  end

  context 'set API_CORS_ORIGINS as "*"' do
    let(:origin) { '*' }
    let(:allow_crendentails) { nil }
    let(:max_age) { '3600' }

    before do
      ENV['API_CORS_ORIGINS'] = origin
      ENV['API_CORS_ALLOW_CREDENTIALS'] = allow_crendentails
      ENV['API_CORS_MAX_AGE'] = max_age
    end

    after do
      ENV['API_CORS_ORIGINS'] = nil
      ENV['API_CORS_ALLOW_CREDENTIALS'] = nil
      ENV['API_CORS_MAX_AGE'] = nil
    end

    it 'sends CORS headers when requesting using GET from frontend url' do
      api_get '/api/v2/account/balances', token: token, headers: { 'Origin' => frontend_url }
      expect(response).to be_successful
      check_cors(response, '*', allow_crendentails, max_age)
    end

    it 'sends CORS headers when requesting using GET from localhost' do
      api_get '/api/v2/account/balances', token: token, headers: { 'Origin' => local_url }
      expect(response).to be_successful
      check_cors(response, '*', allow_crendentails, max_age)
    end
  end

  context 'set multiple API_CORS_ORIGINS for frontend and localhost' do
    let(:allow_crendentails) { 'true' }
    let(:max_age) { '6200' }

    before do
      ENV['API_CORS_ORIGINS'] = "#{frontend_url},#{local_url}"
      ENV['API_CORS_ALLOW_CREDENTIALS'] = allow_crendentails
      ENV['API_CORS_MAX_AGE'] = max_age
    end

    after do
      ENV['API_CORS_ORIGINS'] = nil
      ENV['API_CORS_ALLOW_CREDENTIALS'] = nil
      ENV['API_CORS_MAX_AGE'] = nil
    end

    it 'sends CORS headers when requesting using GET from frontend url' do
      api_get '/api/v2/account/balances', token: token, headers: { 'Origin' => frontend_url }
      expect(response).to be_successful
      check_cors(response, frontend_url, allow_crendentails, max_age)
    end

    it 'sends CORS headers when requesting using GET from localhost' do
      api_get '/api/v2/account/balances', token: token, headers: { 'Origin' => local_url }
      expect(response).to be_successful
      check_cors(response, local_url, allow_crendentails, max_age)
    end

    it 'doesn\'t sends CORS headers when requesting using GET from unkown domain' do
      api_get '/api/v2/account/balances', token: token, headers: { 'Origin' => 'http://domain.com' }
      expect(response).to be_successful
      without_cors(response)
    end
  end

  context 'send invalid request' do
    let(:allow_crendentails) { 'true' }

    before do
      ENV['API_CORS_ORIGINS'] = "#{frontend_url},#{local_url}"
      ENV['API_CORS_ALLOW_CREDENTIALS'] = allow_crendentails
    end

    after do
      ENV['API_CORS_ORIGINS'] = nil
      ENV['API_CORS_ALLOW_CREDENTIALS'] = nil
    end

    it 'sends CORS headers ever when user is not authenticated' do
      api_get '/api/v2/account/balances', headers: { 'Origin' => local_url }
      expect(response).to have_http_status 401
      check_cors(response, local_url, allow_crendentails)
    end

    it 'sends CORS headers when invalid parameter supplied' do
      api_get '/api/v2/account/balances/somecoin', token: token, headers: { 'Origin' => local_url }
      expect(response).to have_http_status 422
      check_cors(response, local_url, allow_crendentails)
    end
  end
end
