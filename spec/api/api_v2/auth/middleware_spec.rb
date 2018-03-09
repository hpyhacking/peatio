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

  context 'when using JWT authentication' do
    let(:member) { create(:member, :verified_identity) }
    let(:payload) { { x: 'x', y: 'y', z: 'z', email: member.email } }
    let(:token) { jwt_build(payload) }

    it 'should deny access when token is not given' do
      api_get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when invalid token is given' do
      api_get '/', token: '123.456.789'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should deny access when member doesn\'t exist' do
      payload[:email] = 'foo@bar.baz'
      api_get '/', token: token
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'should allow access when valid token is given' do
      api_get '/', token: token
      expect(response).to be_success
      expect(response.body).to eq member.email
    end
  end

  context 'when not using authentication' do
    it 'should deny access' do
      api_get '/'
      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end
  end
end
