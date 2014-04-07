require 'spec_helper'

describe APIv2::Members do

  let(:member) do
    create(:verified_member).tap {|m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:cny).update_attributes(balance: 2014.47, locked: 0)
    }
  end
  let(:token)  { create(:api_token, member: member) }

  describe "GET /members/me" do
    before { Currency.stubs(:codes).returns(cny: 1, btc: 2) }

    it "should require authentication" do
      get '/api/v2/members/me'
      response.code.should == '401'
      response.body.should == '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it "should return current user profile with accounts info" do
      signed_get "/api/v2/members/me", token: token
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
