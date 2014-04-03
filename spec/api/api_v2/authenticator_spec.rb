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

  context '#payload' do
    let(:token) { create(:api_token) }
    let(:params) do
      Hashie::Mash.new({
        "access_key" => token.access_key,
        "signature"  => "somehexcode...",
        "foo"        => "bar",
        "hello"      => "world",
        "route_info" => Grape::Route.new
      })
    end

    it "should combine parameters to payload" do
      auth = APIv2::Authenticator.new(nil, params)
      auth.payload.should == "access_key=#{token.access_key}&foo=bar&hello=world"
    end
  end

end
