require 'spec_helper'

describe OldMatching, performance: true do

  MANY = 30

  let(:alice) { who_is_billionaire(:alice) }
  let(:bob) { who_is_billionaire(:bob) }

  context "exact matching #{MANY} asks with #{MANY} bids" do
    let(:latest_price) { '0.0'.to_d }

    before do
      @prepare = Benchmark.realtime do
        price = "10.0".to_d
        volume = "1.0".to_d

        MANY.times do
          create(:order_ask, price: price, volume: volume, member: alice)
          create(:order_bid, price: price, volume: volume, member: bob)
        end
      end
    end

    it "should match all orders in short time" do
      elapsed = Benchmark.realtime do
        expect do
          MANY.times do
            OldMatching.new(:cnybtc).run(latest_price)
          end
        end.to change(Trade, :count).by(MANY)
      end

      elapsed.should < 1

      print_time(prepare: @prepare, process: elapsed)
    end
  end

end
