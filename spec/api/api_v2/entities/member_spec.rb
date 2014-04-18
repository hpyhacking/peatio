require 'spec_helper'

describe APIv2::Entities::Member do

  let(:member) { create(:verified_member) }

  subject { OpenStruct.new APIv2::Entities::Member.represent(member).serializable_hash }

  before { Currency.stubs(:codes).returns(%w(cny btc)) }

  its(:sn)        { should == member.sn }
  its(:name)      { should == member.name }
  its(:email)     { should == member.email }
  its(:activated) { should == true }
  its(:accounts)  { should =~ [{:currency=>"cny", :balance=>"0.0", :locked=>"0.0"}, {:currency=>"btc", :balance=>"0.0", :locked=>"0.0"}] }

end
