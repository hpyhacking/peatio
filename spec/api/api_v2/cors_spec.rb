# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Members, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  def check_cors(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('https://peatio.tech')
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
    expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, X-Requested-With, Content-Type, Accept, Authorization')
    expect(response.headers['Access-Control-Allow-Credentials']).to eq('false')
  end

  before { ENV['API_CORS_ORIGINS'] = 'https://peatio.tech' }

  it 'sends CORS headers when requesting using OPTIONS' do
    reset! unless integration_session
    integration_session.send :process, 'OPTIONS', '/api/v2/members/me'
    expect(response).to be_success
    check_cors(response)
  end

  it 'sends CORS headers when requesting using GET' do
    api_get '/api/v2/members/me', token: token
    expect(response).to be_success
    check_cors(response)
  end

  it 'sends CORS headers ever when user is not authenticated' do
    api_get '/api/v2/members/me'
    expect(response).to have_http_status 401
    check_cors(response)
  end

  it 'sends CORS headers when invalid parameter supplied' do
    api_get '/api/v2/deposits', token: token, params: { currency: 'uah' }
    expect(response).to have_http_status 422
    check_cors(response)
  end
end
