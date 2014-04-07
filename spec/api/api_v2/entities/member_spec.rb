require 'spec_helper'

describe APIv2::Entities::Member do

  let(:member) { create(:member) }

  subject { OpenStruct.new APIv2::Entities::Member.represent(member).serializable_hash }

  its(:sn)        { should == member.sn }
  its(:name)      { should == member.name }
  its(:email)     { should == member.email }
  its(:activated) { should == member.activated }

end
