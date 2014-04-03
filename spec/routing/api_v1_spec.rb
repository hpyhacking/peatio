require "spec_helper"

describe "routes for api v1" do
  let(:codes) { {:xxxyyy => 1} }

  before do
    Market.stubs(:enumerize).returns(codes)
  end

  it "routes tickers api" do
    { get: '/api/tickers/xxxyyy' }.should be_routable
    { get: '/api/tickers/yyyxxx' }.should_not be_routable
  end

end
