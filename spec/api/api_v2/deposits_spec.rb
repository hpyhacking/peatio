require 'spec_helper'

describe APIv2::Deposits do

  let(:member) { create(:member) }
  let(:other_member) { create(:member) }
  let(:token)  { create(:api_token, member: member) }

  describe "GET /api/v2/deposits" do

    before do
      create(:deposit, member: member, currency: 'btc')
      create(:deposit, member: member, currency: 'cny')
      create(:deposit, member: member, currency: 'cny', txid: 1, amount: 520)
      create(:deposit, member: member, currency: 'btc', created_at: 2.day.ago,  txid: 'test', amount: 111)
      create(:deposit, member: other_member, currency: 'cny', txid: 10)
    end

    it "should require deposits authentication" do
      get '/api/v2/deposits', token: token
      response.code.should =='401'
    end

    it "login deposits" do
      signed_get '/api/v2/deposits', token: token
      response.should be_success
    end

    it "deposits num" do
      signed_get '/api/v2/deposits', token: token
      JSON.parse(response.body).size.should == 3
    end

    it "should return limited deposits" do
      signed_get '/api/v2/deposits', params: {limit: 1}, token: token
      JSON.parse(response.body).size.should == 1
    end

    it "should filter deposits by state" do
      signed_get '/api/v2/deposits', params: {state: 'cancelled'}, token: token
      JSON.parse(response.body).size.should == 0

      d = create(:deposit, member: member, currency: 'btc')
      d.submit!
      signed_get '/api/v2/deposits', params: {state: 'submitted'}, token: token
      json = JSON.parse(response.body)
      json.size.should == 1
      json.first['txid'].should == d.txid
    end

    it "deposits currency cny" do
      signed_get '/api/v2/deposits', params: {currency: 'cny'}, token: token
      result = JSON.parse(response.body)
      result.should have(2).deposits
      result.all? {|d| d['currency'] == 'cny' }.should be_true
    end

    it "should return 404 if txid not exist" do
      signed_get '/api/v2/deposit', params: {txid: 5}, token: token
      response.code.should == '404'
    end

    it "should return 404 if txid not belongs_to you " do
      signed_get '/api/v2/deposit', params: {txid: 10}, token: token
      response.code.should == '404'
    end

    it "should ok txid if exist" do
      signed_get '/api/v2/deposit', params: {txid: 1}, token: token

      response.code.should == '200'
      JSON.parse(response.body)['amount'].should == '520.0'
    end

    it "should return deposit no time limit " do
      signed_get '/api/v2/deposit', params: {txid: 'test'}, token: token

      response.code.should == '200'
      JSON.parse(response.body)['amount'].should == '111.0'
    end
  end
end
