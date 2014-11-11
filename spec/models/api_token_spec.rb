require 'spec_helper'

describe APIToken do

  let(:token) { create(:api_token, scopes: '') }

  it "should generate keys before validation on create" do
    token.access_key.size.should == 40
    token.secret_key.size.should == 40
  end

  it "should not change keys on update" do
    access_key = token.access_key
    secret_key = token.secret_key

    token.member_id = 999
    token.save && token.reload

    token.access_key.should == access_key
    token.secret_key.should == secret_key
  end

  it "should allow ip if ip filters is not set" do
    token.allow_ip?('127.0.0.1').should == true
    token.allow_ip?('127.0.0.2').should == true
  end

  it "should allow ip if ip is in ip whitelist" do
    token.trusted_ip_list = %w(127.0.0.1)
    token.allow_ip?('127.0.0.1').should == true
    token.allow_ip?('127.0.0.2').should == false
  end

  it "should tranlsate comma seperated whitelist to trusted ip list" do
    token.ip_whitelist = "127.0.0.1, 127.0.0.2,127.0.0.3"
    token.trusted_ip_list = %w(127.0.0.1 127.0.0.2 127.0.0.3)
  end

  it "should return empty array if no scopes given" do
    token.scopes.should be_empty
  end

  it "should return scopes array" do
    token.scopes = 'foo bar'
    token.scopes.should == %w(foo bar)
  end

  it "should return false if out of scope" do
    token.in_scopes?(%w(foo)).should be_false
  end

  it "should return true if in scope" do
    token.scopes = 'foo'
    token.in_scopes?(%w(foo)).should be_true
  end

  it "should return true if token has all scopes" do
    token.scopes = 'all'
    token.in_scopes?(%w(foo)).should be_true
    token.in_scopes?(%w(bar)).should be_true
  end

  it "should return true if api require no scope" do
    token.in_scopes?(nil).should be_true
    token.in_scopes?([]).should be_true
  end

  it "should destroy itself only" do
    token.destroy
    APIToken.find_by_id(token).should be_nil
  end

  it "should destroy dependent oauth access token" do
    app =Doorkeeper::Application.create!(name: 'test', uid: 'foo', secret: 'bar', redirect_uri: 'http://test.host/oauth/callback')
    access_token = Doorkeeper::AccessToken.create!(application_id: app.id, resource_owner_id: create(:member).id, scopes: 'profile', expires_in: 1.week)

    token.update_attributes oauth_access_token_id: access_token.id
    token.destroy

    Doorkeeper::AccessToken.find_by_id(access_token).should be_nil
  end

end
