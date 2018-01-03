describe APIv2::Auth::KeypairAuthenticator do
  Authenticator = APIv2::Auth::KeypairAuthenticator

  let(:token) { create(:api_token) }
  let(:tonce) { time_to_milliseconds }

  let(:endpoint) do
    stub('endpoint', options: { route_options: { scopes: ['identity'] } })
  end

  let(:request) do
    stub(
      'request',
      request_method: 'GET',
      path_info: '/',
      env: { 'api.endpoint' => endpoint }
    )
  end

  let(:payload) { "GET|/api/|access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  let(:params) do
    Hashie::Mash.new(
      access_key: token.access_key,
      tonce:      tonce,
      foo:        'bar',
      hello:      'world',
      signature:  APIv2::Auth::Utils.hmac_signature(token.secret_key, payload)
    )
  end

  subject { Authenticator.new(request, params) }

  it { expect(subject.authenticate!).to eq token }
  it { expect(subject.token).to eq token }

  it { expect(subject.canonical_verb).to eq 'GET' }
  it { expect(subject.canonical_uri).to eq '/' }
  it { expect(subject.canonical_params).to eq "access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  it 'should not be authentic without access key' do
    params[:access_key] = ''
    expect { subject.authenticate! }.to raise_error(APIv2::InvalidAccessKeyError)
  end

  it 'should not be authentic without signature' do
    subject
    params[:signature] = nil
    expect { subject.authenticate! }.to raise_error(APIv2::IncorrectSignatureError)
  end

  it 'should not be authentic without tonce' do
    params[:tonce] = nil
    params[:signature] = APIv2::Auth::Utils.hmac_signature(token.secret_key, "GET|/|access_key=#{token.access_key}&foo=bar&hello=world&tonce=")
    expect { subject.authenticate! }.to raise_error(APIv2::InvalidTonceError)
  end

  it 'should return false on unmatched signature' do
    params[:signature] = 'fake'
    expect { subject.authenticate! }.to raise_error(APIv2::IncorrectSignatureError)
  end

  it 'should be invalid if tonce is not within 30s' do
    params[:tonce] = time_to_milliseconds(31.seconds.ago)
    expect {
      Authenticator.new(request, params).check_tonce!
    }.to raise_error(APIv2::InvalidTonceError)

    params[:tonce] = time_to_milliseconds(31.seconds.since)
    expect {
      Authenticator.new(request, params).check_tonce!
    }.to raise_error(APIv2::InvalidTonceError)
  end

  it 'should not be authentic on repeated tonce' do
    params[:tonce] = time_to_milliseconds(Time.now)
    subject.check_tonce!
    expect { subject.check_tonce! }.to raise_error(APIv2::TonceUsedError)
  end

  it 'should not be authentic for invalid token' do
    params[:access_key] = 'fake'
    expect(subject.token).to be_nil
    expect { subject.authenticate! }.to raise_error(APIv2::InvalidAccessKeyError)
  end

  it 'should be authentic if associated member is disabled' do
    token.member.update_attributes disabled: true
    expect {
      expect(subject.token).to_not be_nil
      subject.authenticate!
    }.to_not raise_error
  end

  it 'should not be authentic if api access is disabled' do
    token.member.update_attributes api_disabled: true
    expect { subject.authenticate! }.to raise_error(APIv2::DisabledAccessKeyError)
  end

  it 'should not be authentic if token is expired' do
    token.update_attributes expires_at: 1.second.ago
    expect { subject.authenticate! }.to raise_error(APIv2::ExpiredAccessKeyError)
  end

  it 'should not be authentic if token is soft deleted' do
    token.destroy
    expect(APIToken.find_by_id(token.id)).to be_nil
    expect(APIToken.with_deleted.find_by_id(token.id)).to eq(token)
    expect { subject.authenticate! }.to raise_error(APIv2::InvalidAccessKeyError)
  end
end
