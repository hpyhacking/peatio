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
  let(:params) do
    Hashie::Mash.new({
      "access_key" => token.access_key,
      "signature"  => "somehexcode...", # wrong signature
      "foo"        => "bar",
      "hello"      => "world",
      "route_info" => Grape::Route.new
    })
  end

  subject { APIv2::Authenticator.new(nil, params) }

  its(:token)   { should == token }
  its(:payload) { should == "access_key=#{token.access_key}&foo=bar&hello=world" }

  context "invalid request" do
    its(:authentic?)       { should be_false }
    its(:signature_match?) { should be_false }
  end

  context "authentic request" do
    before do
      params[:signature] = APIv2::Authenticator.hmac_signature(token.secret_key, subject.payload)
    end

    its(:authentic?)       { should be_true }
    its(:signature_match?) { should be_true }
  end

end
