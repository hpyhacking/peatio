require 'spec_helper'

describe Worker::Matching do

  let(:alice)  { who_is_billionaire(:alice) }
  let(:bob)    { who_is_billionaire(:bob) }
  let(:market) { Market.find('btccny') }

  subject { Worker::Matching.new }

  context "engines" do
    let(:attrs)  { create(:order_bid, currency: 'btccny').to_matching_attributes }
    let(:order)  { ::Matching::Order.new attrs }

    before do
      subject.instance_variable_set('@order', order)
    end

    it "should find or initialize engine for market" do
      subject.engine.should be_instance_of(::Matching::FIFOEngine)
    end

    it "should get all engines" do
      subject.engine
      subject.engines.keys.should == [order.market.id]
    end
  end

  context "match existing order on restart" do
    let!(:ask) { create(:order_ask, price: '3999', volume: '10.0', member: alice) }
    let!(:bid) { create(:order_bid, price: '3999', volume: '10.0', member: bob) }

    it "should submit existing order only once after engine restart" do
      engine = mock('engine')
      engine.expects(:submit!).times(2) # 1 for ask, 1 for bid
      ::Matching::FIFOEngine.expects(:new).returns(engine)
      subject.process action: 'submit', order: bid.to_matching_attributes
    end

    it "should not match existing orders if one is canceled on engine restart" do
      engine = mock('engine')
      engine.expects(:submit!).once # ask
      engine.expects(:cancel!).once # bid
      ::Matching::FIFOEngine.expects(:new).returns(engine)
      subject.process  action: 'cancel', order: bid.to_matching_attributes
    end

  end

  context "full match" do
    let(:bid) { create(:order_bid, price: '3999', volume: '10.0', member: bob) }
    let(:order) { create(:order_ask, price: '3999', volume: '10.0', member: alice) }

    before do
      subject.process action: 'submit', order: bid.to_matching_attributes
      subject.process action: 'submit', order: order.to_matching_attributes
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
      subject.process action: 'submit', order: existing.to_matching_attributes
    end

    it "should match part of existing order" do
      order = create(:order_bid, price: '4001', volume: '8.0', member: bob)

      expect {
        subject.process action: 'submit', order: order.to_matching_attributes

        order.reload.state.should        == ::Order::DONE
        existing.reload.state.should_not == ::Order::DONE
        existing.reload.volume.should    == '2.0'.to_d
      }.to change(Trade, :count).by(1)
    end

    it "should match part of new order" do
      order = create(:order_bid, price: '4001', volume: '12.0', member: bob)

      expect {
        subject.process action: 'submit', order: order.to_matching_attributes

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
        subject.process action: 'submit', order: ask1.to_matching_attributes
        subject.process action: 'submit', order: ask2.to_matching_attributes
      }.not_to change(Trade, :count)

      expect {
        subject.process action: 'submit', order: bid3.to_matching_attributes
        ask1.reload.state.should  == Order::DONE
        ask2.reload.state.should  == Order::DONE
        bid3.reload.volume.should == '2.0'.to_d
      }.to change(Trade, :count).by(2)

      expect {
        subject.process action: 'submit', order: ask4.to_matching_attributes
        bid3.reload.state.should   == Order::DONE
        ask4.reload.volume.should  == '3.0'.to_d
        market.latest_price.should == '4003'.to_d
      }.to change(Trade, :count).by(1)

      expect {
        subject.process action: 'submit', order: bid5.to_matching_attributes
        ask4.reload.state.should   == Order::DONE
        bid5.reload.state.should   == Order::DONE
        market.latest_price.should == '4002'.to_d
      }.to change(Trade, :count).by(1)

      expect {
        subject.process action: 'submit', order: bid6.to_matching_attributes
      }.not_to change(Trade, :count)
    end
  end

end
