require 'spec_helper'

describe APIv2::Auth::Authenticator do
  Authenticator = APIv2::Auth::Authenticator

  let(:token) { create(:api_token) }
  let(:tonce) { time_to_milliseconds }

  let(:endpoint) { stub('endpoint', options: {route_options: {scopes: ['identity']}})}
  let(:request) { stub('request', request_method: 'GET', path_info: '/', env: {'api.endpoint' => endpoint}) }
  let(:payload) { "GET|/api/|access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  let(:params) do
    Hashie::Mash.new({
      "access_key" => token.access_key,
      "tonce"      => tonce,
      "foo"        => "bar",
      "hello"      => "world",
      "route_info" => Grape::Route.new,
      "signature"  => APIv2::Auth::Utils.hmac_signature(token.secret_key, payload)
    })
  end

  subject { Authenticator.new(request, params) }

  its(:authenticate!)          { should == token }
  its(:token)                  { should == token }
  its(:canonical_verb)         { should == 'GET' }
  its(:canonical_uri)          { should == '/' }
  its(:canonical_query)        { should == "access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  it "should not be authentic without access key" do
    params[:access_key] = ''
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::InvalidAccessKeyError)
  end

  it "should not be authentic without signature" do
    subject
    params[:signature] = nil
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::IncorrectSignatureError)
  end

  it "should not be authentic without tonce" do
    params[:tonce] = nil
    params[:signature] = APIv2::Auth::Utils.hmac_signature(token.secret_key, "GET|/|access_key=#{token.access_key}&foo=bar&hello=world&tonce=")
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::InvalidTonceError)
  end

  it "should return false on unmatched signature" do
    params[:signature] = 'fake'
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::IncorrectSignatureError)
  end

  it "should be invalid if tonce is not within 30s" do
    params[:tonce] = time_to_milliseconds(31.seconds.ago)
    lambda {
      Authenticator.new(request, params).check_tonce!
    }.should raise_error(APIv2::InvalidTonceError)

    params[:tonce] = time_to_milliseconds(31.seconds.since)
    lambda {
      Authenticator.new(request, params).check_tonce!
    }.should raise_error(APIv2::InvalidTonceError)
  end

  it "should not be authentic on repeated tonce" do
    params[:tonce] = time_to_milliseconds(Time.now)
    subject.check_tonce!

    lambda {
      subject.check_tonce!
    }.should raise_error(APIv2::TonceUsedError)
  end

  it "should not be authentic for invalid token" do
    params[:access_key] = 'fake'
    subject.token.should be_nil
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::InvalidAccessKeyError)
  end

  it "should be authentic if associated member is disabled" do
    token.member.update_attributes disabled: true
    lambda {
      subject.token.should_not be_nil
      subject.authenticate!
    }.should_not raise_error
  end

  it "should not be authentic if api access is disabled" do
    token.member.update_attributes api_disabled: true
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::DisabledAccessKeyError)
  end

  it "should not be authentic if token is expired" do
    token.update_attributes expire_at: 1.second.ago
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::ExpiredAccessKeyError)
  end

  it "should not be authentic if token is soft deleted" do
    token.destroy
    APIToken.find_by_id(token.id).should be_nil
    APIToken.with_deleted.find_by_id(token.id).should == token
    lambda {
      subject.authenticate!
    }.should raise_error(APIv2::InvalidAccessKeyError)
  end
end
