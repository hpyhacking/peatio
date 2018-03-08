describe APIv2::Members, type: :request do
  let(:member) { create :member, :verified_identity }
  let(:token) { jwt_for(member) }

  def check_cors(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('https://peatio.tech')
    expect(response.headers['Access-Control-Allow-Methods']).to eq('GET, POST, PUT, PATCH, DELETE')
    expect(response.headers['Access-Control-Allow-Headers']).to eq('Origin, X-Requested-With, Content-Type, Accept, Authorization')
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
end
