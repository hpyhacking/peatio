describe APIToken do
  let(:token) { create(:api_token, scopes: '') }

  it 'should generate keys before validation on create' do
    expect(token.access_key.size).to eq 40
    expect(token.secret_key.size).to eq 40
  end

  it 'should not change keys on update' do
    access_key = token.access_key
    secret_key = token.secret_key

    token.member_id = 999
    token.save && token.reload

    expect(token.access_key).to eq access_key
    expect(token.secret_key).to eq secret_key
  end

  it 'should allow ip if ip filters is not set' do
    expect(token.allow_ip?('127.0.0.1')).to be true
    expect(token.allow_ip?('127.0.0.2')).to be true
  end

  it 'should allow ip if ip is in ip whitelist' do
    token.trusted_ip_list = %w[127.0.0.1]
    expect(token.allow_ip?('127.0.0.1')).to be true
    expect(token.allow_ip?('127.0.0.2')).to be false
  end

  it 'should tranlsate comma seperated whitelist to trusted ip list' do
    token.ip_whitelist = '127.0.0.1, 127.0.0.2,127.0.0.3'
    token.trusted_ip_list = %w[127.0.0.1 127.0.0.2 127.0.0.3]
  end

  it 'should return empty array if no scopes given' do
    expect(token.scopes).to be_empty
  end

  it 'should return scopes array' do
    token.scopes = 'foo bar'
    expect(token.scopes).to eq %w[foo bar]
  end

  it 'should return false if out of scope' do
    expect(token.in_scopes?(%w[foo])).to be false
  end

  it 'should return true if in scope' do
    token.scopes = 'foo'
    expect(token.in_scopes?(%w[foo])).to be true
  end

  it 'should return true if token has all scopes' do
    token.scopes = 'all'
    expect(token.in_scopes?(%w[foo])).to be true
    expect(token.in_scopes?(%w[bar])).to be true
  end

  it 'should return true if api require no scope' do
    expect(token.in_scopes?(nil)).to be true
    expect(token.in_scopes?([])).to be true
  end

  it 'should destroy itself only' do
    token.destroy
    expect(APIToken.find_by_id(token)).to be_nil
  end

  it 'should destroy dependent oauth access token' do
    app = Doorkeeper::Application.create!(name: 'test', uid: 'foo', secret: 'bar', redirect_uri: 'http://test.host/oauth/callback')
    access_token = Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: create(:member).id, scopes: 'profile', expires_in: 1.week)

    token.update_attributes oauth_access_token_id: access_token.id
    token.destroy

    expect(Doorkeeper::AccessToken.find_by_id(access_token)).to be_nil
  end
end
