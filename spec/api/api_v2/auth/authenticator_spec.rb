require 'spec_helper'

describe APIv2::Auth::Authenticator do
  Authenticator = APIv2::Auth::Authenticator

  let(:token) { create(:api_token) }
  let(:tonce) { time_to_milliseconds }

  let(:request) { stub('request', request_method: 'GET', path_info: '/') }
  let(:payload) { "GET\n/\naccess_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

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

  its(:authentic?)             { should be_true }
  its(:signature_match?)       { should be_true }
  its(:fresh?)                 { should be_true }
  its(:token)                  { should == token }
  its(:canonical_verb)         { should == 'GET' }
  its(:canonical_uri)          { should == '/' }
  its(:canonical_query)        { should == "access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  it "should not be authentic without access key" do
    params[:access_key] = ''
    subject.should_not be_authentic
  end

  it "should not be authentic without signature" do
    subject
    params[:signature] = nil
    subject.should_not be_authentic
  end

  it "should not be authentic without tonce" do
    params[:tonce] = nil
    subject.should_not be_authentic
  end

  it "should return false on unmatched signature" do
    subject.signature_match?.should be_true

    params[:signature] = 'fake'
    subject.signature_match?.should be_false
    subject.should_not be_authentic
  end

  it "should be stale if tonce is older than 5 minutes ago" do
    params[:tonce] = time_to_milliseconds(6.minutes.ago)
    subject.should_not be_fresh
    subject.should_not be_authentic
  end

  it "should be stale if tonce is smaller than last seen" do
    subject.should be_fresh
    subject.expects(:tonce).returns(time_to_milliseconds(1.second.ago))
    subject.should_not be_fresh
  end

  it "should not be authentic for invalid token" do
    params[:access_key] = 'fake'
    subject.token.should be_nil
    subject.should_not be_authentic
  end

end
