require 'spec_helper'

module APIv2

  class AuthTest < Grape::API
    get("/auth_test") do
      authenticate!
      'ok'
    end
  end

  class Mount
    mount AuthTest
  end

end

describe APIv2::Helpers do

  context "#authentic?" do

    let!(:token) { create(:api_token) }

    context "Authenticate using headers" do
    end

    context "Authenticate using params" do
      it "should return ok" do
        signature = APIv2::Authenticator.hmac_signature(token.secret_key, '')
        get '/api/v2/auth_test', access_key: token.access_key, signature: signature
        response.should be_success
        response.body.should == 'ok'
      end

      it "should return error" do
        get '/api/v2/auth_test'
        response.code.should == '401'
        response.body.should == 'API Authorization Failed.'
      end
    end

  end

end
