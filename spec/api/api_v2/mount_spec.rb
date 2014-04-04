require 'spec_helper'

module APIv2
  class Mount

    get "/broken" do
      raise Error, code: 2014310, text: 'MtGox bankrupt'
    end

  end
end

describe APIv2::Mount do

  context "exception handling" do
    it "should return error message in json format" do
      get "/api/v2/broken"
      response.code.should == '400'
      JSON.parse(response.body).should == {'error' => {'code' => 2014310, 'message' => "MtGox bankrupt"}}
    end
  end

end
