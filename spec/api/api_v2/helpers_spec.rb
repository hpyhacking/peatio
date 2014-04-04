require 'spec_helper'

module APIv2

  class AuthTest < Grape::API
    get("/auth_test") do
      authenticate!
      current_user
    end
  end

  class Mount
    mount AuthTest
  end

end

describe APIv2::Helpers do

  context "#authentic?" do

    let(:tonce)  { (Time.now.to_f*1000).to_i }
    let!(:token) { create(:api_token) }

    context "Authenticate using headers" do
    end

    context "Authenticate using params" do
      let(:payload) { "access_key=#{token.access_key}&foo=bar&hello=world&tonce=#{tonce}" }
      let(:signature) { APIv2::Authenticator.hmac_signature(token.secret_key, payload) }

      it "should response successfully" do
        get '/api/v2/auth_test', access_key: token.access_key, signature: signature, foo: 'bar', hello: 'world', tonce: tonce
        response.should be_success
      end

      it "should set current user" do
        get '/api/v2/auth_test', access_key: token.access_key, signature: signature, foo: 'bar', hello: 'world', tonce: tonce
        response.body.should == token.member.to_s
      end

      it "should fail authorization" do
        get '/api/v2/auth_test'
        response.code.should == '401'
        response.body.should == 'API Authorization Failed.'
      end
    end

  end

end
