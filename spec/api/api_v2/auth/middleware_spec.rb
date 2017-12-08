describe APIv2::Auth::Middleware, type: :request do
  class TestApp < Grape::API
    helpers APIv2::Helpers
    use APIv2::Auth::Middleware

    get '/' do
      authenticate!
      current_user.email
    end
  end

  let(:app) { TestApp.new }

  context 'when using keypair authentication' do
    let(:token) { create(:api_token) }

    it 'should deny access with incorrect credentials' do
      get '/', access_key: token.access_key, tonce: time_to_milliseconds, signature: 'wrong'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2005,"message":"Signature wrong is incorrect."}}'
    end

    it 'should allow access with correct credentials' do
      signed_get '/', token: token
      expect(response).to be_success
      expect(response.body).to eq token.member.email
    end
  end

  context 'when using JWT authentication' do
    let(:token)   { 'Bearer ' + JWT.encode(payload, APIv2::Auth::Utils.jwt_shared_secret_key, 'RS256') }
    let(:member)  { create(:member) }
    let(:payload) { {x: 'x', y: 'y', z: 'z', email: member.email} }

    it 'should deny access when token is not given' do
      get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when invalid token is given' do
      get '/', nil, { 'Authorization' => 'Bearer 123.456.789' }
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when member doesn\'t exist' do
      payload[:email] = 'foo@bar.baz'
      get '/', nil, { 'Authorization' => token }
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should allow access when valid token is given' do
      get '/', nil, { 'Authorization' => token }
      expect(response).to be_success
      expect(response.body).to eq member.email
    end
  end

  context 'when not using authentication' do
    it 'should deny access' do
      get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end
  end
end
