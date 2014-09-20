require "spec_helper"

describe "routes for trade" do

  it "routes /markets/xxxyyy to the trade controller" do
    Market.expects(:find_by_id).with('xxxyyy').returns(Market.new(id: 'xxxyyy', base_unit: 'xxx', quote_unit: 'yyy'))
    { :get => "/markets/xxxyyy" }.should be_routable

    Market.expects(:find_by_id).with('yyyxxx').returns(nil)
    { :get => "/markets/yyyxxx" }.should_not be_routable
  end

end
