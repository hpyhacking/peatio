require 'spec_helper'

describe Job::Matching do

  let(:alice)  { who_is_billionaire(:alice) }
  let(:bob)    { who_is_billionaire(:bob) }
  let(:market) { Market.find('cnybtc') }

  context "given filled orderbook" do

    let(:fill_ask) { create(:order_ask, price: '4001', volume: '10.0', member: alice) }
    let(:fill_bid) { create(:order_bid, price: '3999', volume: '10.0', member: bob) }

    before do
      ::Job::Matching.perform fill_ask.to_matching_attributes
      ::Job::Matching.perform fill_bid.to_matching_attributes
    end

    context "submit full matching order" do
      let!(:order) { create(:order_ask, price: '3999', volume: '10.0', member: alice) }

      before do
        ::Job::Matching.perform order.to_matching_attributes
      end

      it "should update market's latest price" do
        market.latest_price.should    == 3999.to_d
      end

      it "should execute a full match" do
        order.reload.state.should     == ::Order::DONE
        fill_bid.reload.state.should  == ::Order::DONE

        fill_ask.reload.state.should_not == ::Order::DONE
        fill_ask.reload.volume.should    == '10.0'.to_d
      end
    end

  end

end
