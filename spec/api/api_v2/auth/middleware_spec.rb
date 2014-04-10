require 'spec_helper'

describe APIv2::Auth::Middleware do

  class TestApp
    def call(env)
      if user = env['api_v2.token'].try(:member)
        [200, {}, [user.email]]
      else
        [401, {}, ['Unauthorized.']]
      end
    end
  end

  let(:app) do
    Rack::Builder.app do
      use APIv2::Auth::Middleware
      run TestApp.new
    end
  end

  let(:token) { create(:api_token) }

  it "should refuse request without credentials" do
    get '/'
    response.code.should == '401'
    response.body.should == 'Unauthorized.'
  end

  it "should refuse request with incorrect credentials" do
    get '/', access_key: token.access_key, tonce: (Time.now.to_f*1000).to_i, signature: 'wrong'
    response.code.should == '401'
    response.body.should == 'Unauthorized.'
  end

  it "should authorize request with correct param credentials" do
    signed_get '/', token: token
    response.should be_success
    response.body.should == token.member.email
  end

end
