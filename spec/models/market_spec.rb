require 'spec_helper'

describe Market do

  context 'visible market' do
    # it { expect(Market.orig_all.count).to eq(2) }
    it { expect(Market.all.count).to eq(1) }
  end

  context 'markets hash' do
    it "should list all markets info" do
      Market.to_hash.should == {:btcinr=>{:name=>"BTC/inr", :base_unit=>"btc", :quote_unit=>"inr"}}
    end
  end

  context 'market attributes' do
    subject { Market.find('btcinr') }

    its(:id)         { should == 'btcinr' }
    its(:name)       { should == 'BTC/inr' }
    its(:base_unit)  { should == 'btc' }
    its(:quote_unit) { should == 'inr' }
    its(:visible)    { should be_true }
  end

  context 'enumerize' do
    subject { Market.enumerize }

    it { should be_has_key :btcinr }
    it { should be_has_key :ptsbtc }
  end

  context 'shortcut of global access' do
    subject { Market.find('btcinr') }

    its(:bids)   { should_not be_nil }
    its(:asks)   { should_not be_nil }
    its(:trades) { should_not be_nil }
    its(:ticker) { should_not be_nil }
  end

end
