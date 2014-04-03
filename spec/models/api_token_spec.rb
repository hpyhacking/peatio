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

end
