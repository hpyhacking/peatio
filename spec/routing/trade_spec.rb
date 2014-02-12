require "spec_helper"

describe "routes for trade" do
  let(:codes) { {:xxxyyy => 1} }

  before do 
    Market.stubs(:enumerize).returns(codes)
  end

  it "routes /markets/xxxyyy to the trade controller" do
    { :get => "/markets/xxxyyy" }.should be_routable
    { :get => "/markets/yyyxxx" }.should_not be_routable
  end
end
