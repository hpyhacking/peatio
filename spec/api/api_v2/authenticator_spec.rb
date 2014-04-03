require 'spec_helper'

describe APIv2::Authenticator do

  context '.generate_access_key' do
    it "should be a string longer than 40 characters" do
      APIv2::Authenticator.generate_access_key.should match(/^[a-zA-Z0-9]{40}$/)
    end
  end

  context '.generate_secret_key' do
    it "should be a string longer than 40 characters" do
      APIv2::Authenticator.generate_secret_key.should match(/^[a-zA-Z0-9]{40}$/)
    end
  end

  let(:token) { create(:api_token) }
  let(:tonce) { (Time.now.to_f*1000).to_i }

  let(:params) do
    Hashie::Mash.new({
      "access_key" => token.access_key,
      "tonce"      => tonce,
      "foo"        => "bar",
      "hello"      => "world",
      "route_info" => Grape::Route.new
    })
  end

  subject do
    auth               = APIv2::Authenticator.new(nil, params)
    params[:signature] = APIv2::Authenticator.hmac_signature(token.secret_key, auth.payload)
    auth
  end

  its(:authentic?)             { should be_true }
  its(:signature_match?)       { should be_true }
  its(:required_params_exist?) { should be_true }
  its(:fresh?)                 { should be_true }
  its(:token)                  { should == token }
  its(:payload)                { should == "access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }

  it "should require access_key" do
    params[:access_key] = ''
    subject.required_params_exist?.should be_false
    subject.should_not be_authentic
  end

  it "should require tonce" do
    params[:tonce] = ''
    subject.required_params_exist?.should be_false
    subject.should_not be_authentic
  end

  it "should require signature" do
    subject.required_params_exist?.should be_true

    params[:signature] = ''
    subject.required_params_exist?.should be_false
    subject.should_not be_authentic
  end

  it "should return false on unmatched signature" do
    subject.signature_match?.should be_true

    params[:signature] = 'fake'
    subject.signature_match?.should be_false
    subject.should_not be_authentic
  end

  it "should be stale if tonce is older than 5 minutes ago" do
    params[:tonce] = 6.minutes.ago
    subject.should_not be_fresh
    subject.should_not be_authentic
  end

  it "should not be authentic for invalid token" do
    params[:access_key] = 'fake'
    subject.token.should be_nil
    subject.should_not be_authentic
  end

end
