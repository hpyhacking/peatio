require 'spec_helper'

describe APIv2::Deposits do

  let(:member) { create(:member) }
  let(:token)  { create(:api_token, member: member) }

  describe "GET /api/v2/deposits" do
    it "should require authentication" do
      get '/api/v2/deposits', token: token

      response.code.should =='401'
    end

    it "login deposits" do
      signed_get '/api/v2/deposits', token: token

      response.should be_success
    end

  end
end
