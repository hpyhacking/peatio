require 'spec_helper'

describe APIv2::Entities::Account do

  let(:account) { create(:account_btc) }

  subject { OpenStruct.new APIv2::Entities::Account.represent(account).serializable_hash }

  its(:currency) { should == 'btc' }
  its(:balance)  { should == '100.0'}
  its(:locked)   { should == '0.0' }

end
