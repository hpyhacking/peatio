require 'spec_helper'

describe Doorkeeper::AccessToken do

  let(:app) { Doorkeeper::Application.create!(name: 'test', uid: 'foo', secret: 'bar', redirect_uri: 'http://test.host/oauth/callback') }
  let(:member) { create(:member) }

  context "creation" do
    subject! { Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: member.id, scopes: 'identity', expires_in: 1.week) }

    it "should generate corresponding api token" do
      lambda {
        Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: member.id, scopes: 'identity', expires_in: 1.week)
      }.should change(APIToken, :count).by(1)
    end

    it "should set token" do
      subject.token.should == APIToken.last.to_oauth_token
    end

    it "should setup api token correctly" do
      api_token = APIToken.last
      api_token.label.should == app.name
      api_token.scopes.should == %w(identity)
      api_token.expire_at.should_not be_nil
    end

    it "should link api token" do
      APIToken.last.oauth_access_token.should == subject
    end
  end


end
