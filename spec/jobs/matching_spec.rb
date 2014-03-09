require 'spec_helper'

describe Job::Matching do

  let(:alice)  { who_is_billionaire(:alice) }
  let(:bob)    { who_is_billionaire(:bob) }
  let(:market) { Market.find('cnybtc') }

  before do
    Job::Matching.reset_engines
  end

  context "engines" do
    it "should find or initialize engine for market" do
      Job::Matching.engine_for(market).should be_instance_of(::Matching::FIFOEngine)
    end

    it "should get all engines" do
      Job::Matching.engine_for(market)
      Job::Matching.engines.keys.should == [market.id]
    end

    it "should reset engines" do
      Job::Matching.engine_for(market)
      Job::Matching.reset_engines
      Job::Matching.engines.should be_empty
    end
  end

  context "full match" do
    let(:bid) { create(:order_bid, price: '3999', volume: '10.0', member: bob) }
    let(:order) { create(:order_ask, price: '3999', volume: '10.0', member: alice) }

    before do
      ::Job::Matching.perform bid.to_matching_attributes
      ::Job::Matching.perform order.to_matching_attributes
    end

    it "should update market's latest price" do
      market.latest_price.should == 3999.to_d
    end

    it "should execute a full match" do
      order.reload.state.should     == ::Order::DONE
      bid.reload.state.should  == ::Order::DONE
    end
  end

  context "partial match" do
    let(:existing) { create(:order_ask, price: '4001', volume: '10.0', member: alice) }

    before do
      ::Job::Matching.perform existing.to_matching_attributes
    end

    it "should match part of existing order" do
      order = create(:order_bid, price: '4001', volume: '8.0', member: bob)

      expect {
        ::Job::Matching.perform order.to_matching_attributes

        order.reload.state.should        == ::Order::DONE
        existing.reload.state.should_not == ::Order::DONE
        existing.reload.volume.should    == '2.0'.to_d
      }.to change(Trade, :count).by(1)
    end

    it "should match part of new order" do
      order = create(:order_bid, price: '4001', volume: '12.0', member: bob)

      expect {
        ::Job::Matching.perform order.to_matching_attributes

        order.reload.state.should_not == ::Order::DONE
        order.reload.volume.should    == '2.0'.to_d
        existing.reload.state.should  == ::Order::DONE
      }.to change(Trade, :count).by(1)
    end
  end

  context "complex partial match" do
    # submit  | ask price/volume | bid price/volume |
    # -----------------------------------------------
    # ask1    | 4003/3           |                  |
    # -----------------------------------------------
    # ask2    | 4002/3, 4003/3   |                  |
    # -----------------------------------------------
    # bid3    |                  | 4003/2           |
    # -----------------------------------------------
    # ask4    | 4002/3           |                  |
    # -----------------------------------------------
    # bid5    |                  |                  |
    # -----------------------------------------------
    # bid6    |                  | 4001/5           |
    # -----------------------------------------------
    let(:ask1) { create(:order_ask, price: '4003', volume: '3.0', member: alice) }
    let(:ask2) { create(:order_ask, price: '4002', volume: '3.0', member: alice) }
    let(:bid3) { create(:order_bid, price: '4003', volume: '8.0', member: bob) }
    let(:ask4) { create(:order_ask, price: '4002', volume: '5.0', member: alice) }
    let(:bid5) { create(:order_bid, price: '4003', volume: '3.0', member: bob) }
    let(:bid6) { create(:order_bid, price: '4001', volume: '5.0', member: bob) }

    it "should create many trades" do
      expect {
        ::Job::Matching.perform ask1.to_matching_attributes
        ::Job::Matching.perform ask2.to_matching_attributes
      }.not_to change(Trade, :count)

      expect {
        ::Job::Matching.perform bid3.to_matching_attributes
        ask1.reload.state.should  == Order::DONE
        ask2.reload.state.should  == Order::DONE
        bid3.reload.volume.should == '2.0'.to_d
      }.to change(Trade, :count).by(2)

      expect {
        ::Job::Matching.perform ask4.to_matching_attributes
        bid3.reload.state.should   == Order::DONE
        ask4.reload.volume.should  == '3.0'.to_d
        market.latest_price.should == '4003'.to_d
      }.to change(Trade, :count).by(1)

      expect {
        ::Job::Matching.perform bid5.to_matching_attributes
        ask4.reload.state.should   == Order::DONE
        bid5.reload.state.should   == Order::DONE
        market.latest_price.should == '4002'.to_d
      }.to change(Trade, :count).by(1)

      expect {
        ::Job::Matching.perform bid6.to_matching_attributes
      }.not_to change(Trade, :count)
    end
  end

end
