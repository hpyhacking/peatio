require 'spec_helper'

describe APIv2::Auth::Middleware do

  class TestApp < Grape::API
    helpers APIv2::Helpers
    use APIv2::Auth::Middleware

    get '/' do
      authenticate!
      current_user.email
    end
  end

  let(:app) do
    TestApp.new
  end

  let(:token) { create(:api_token) }

  it "should refuse request without credentials" do
    get '/'
    response.code.should == '401'
    response.body.should == "{\"error\":{\"code\":2001,\"message\":\"Authorization failed\"}}"
  end

  it "should refuse request with incorrect credentials" do
    get '/', access_key: token.access_key, tonce: time_to_milliseconds, signature: 'wrong'
    response.code.should == '401'
    response.body.should == "{\"error\":{\"code\":2005,\"message\":\"Signature wrong is incorrect.\"}}"
  end

  it "should authorize request with correct param credentials" do
    signed_get '/', token: token
    response.should be_success
    response.body.should == token.member.email
  end

end
