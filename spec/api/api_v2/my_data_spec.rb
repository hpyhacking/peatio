require 'spec_helper'

describe APIv2::MyData do

  let(:member) do
    create(:verified_member).tap {|m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:cny).update_attributes(balance: 2014.47, locked: 0)
    }
  end
  let(:token)  { create(:api_token, member: member) }

  before { Currency.stubs(:codes).returns(cny: 1, btc: 2) }

  describe "GET /my/info" do

    it "should require authentication" do
      get '/api/v2/my/info'
      response.code.should == '401'
      response.body.should == '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it "should return current user profile with accounts info" do
      signed_get "/api/v2/my/info", token: token
      response.should be_success

      result = JSON.parse(response.body)
      result['sn'].should == member.sn
      result['activated'].should == true
      result['accounts'].should =~ [
        {"currency" => "cny", "balance" => "2014.47", "locked" => "0.0"},
        {"currency" => "btc", "balance" =>"12.13",    "locked" => "3.14"}
      ]
    end

  end

end
