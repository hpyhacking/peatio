require 'spec_helper'

module APIv2
  class Mount

    get "/null" do
      ''
    end

    get "/broken" do
      raise Error, code: 2014310, text: 'MtGox bankrupt'
    end

  end
end

describe APIv2::Mount do

  it "should use auth and attack middleware" do
    APIv2::Mount.middleware.should == [[APIv2::Auth::Middleware], [Rack::Attack]]
  end

  it "should allow 3rd party ajax call" do
    get "/api/v2/null"
    response.should be_success
    response.headers['Access-Control-Allow-Origin'].should == '*'
  end

  context "handle exception on request processing" do
    it "should render json error message" do
      get "/api/v2/broken"
      response.code.should == '400'
      JSON.parse(response.body).should == {'error' => {'code' => 2014310, 'message' => "MtGox bankrupt"}}
    end
  end

  context "handle exception on request routing" do
    it "should render json error message" do
      get "/api/v2/non/exist"
      response.code.should == '404'
      response.body.should == "Not Found"
    end
  end

end
