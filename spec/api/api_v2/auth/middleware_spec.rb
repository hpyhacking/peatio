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
  let(:token) { create(:api_token) }

  it 'should refuse request without credentials' do
    get '/'
    expect(response.code).to eq '401'
    expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
  end

  it 'should refuse request with incorrect credentials' do
    get '/', access_key: token.access_key, tonce: time_to_milliseconds, signature: 'wrong'
    expect(response.code).to eq '401'
    expect(response.body).to eq '{"error":{"code":2005,"message":"Signature wrong is incorrect."}}'
  end

  it 'should authorize request with correct param credentials' do
    signed_get '/', token: token
    expect(response).to be_success
    expect(response.body).to eq token.member.email
  end
end
