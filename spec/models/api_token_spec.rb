require 'spec_helper'

describe APIToken do

  let(:token) { create(:api_token) }

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
    token.has_scope?('foo').should be_false
  end

  it "should return true if in scope" do
    token.scopes = 'foo'
    token.has_scope?('foo').should be_true
  end

  it "should return true if token has all scopes" do
    token.scopes = 'all'
    token.has_scope?('foo').should be_true
    token.has_scope?('bar').should be_true
  end

end
