require 'spec_helper'

describe Market do

  subject { Market.find('btccny') }

  its(:id)        { should == 'btccny' }
  its(:name)      { should == 'BTC/CNY' }
  its(:commodity) { should == {ask: 'btc', bid: 'cny'} }

end
