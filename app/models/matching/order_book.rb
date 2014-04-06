module Matching
  class OrderBook

    def initialize
      @tree = {ask: RBTree.new, bid: RBTree.new}
    end

    def submit(order)
      @tree[order.type][order] = true
      order
    end

    def cancel(order)
      @tree[order.type].delete order
    end

    def lowest_ask
      @tree[:ask].first[0]
    end

    def highest_bid
      @tree[:bid].last[0]
    end

    def matchable?
      !@tree[:ask].empty? && !@tree[:bid].empty?
    end

    def pop_closest_pair!
      [delete_ask(lowest_ask), delete_bid(highest_bid)]
    end

    def delete_ask(ask)
      @tree[:ask].delete ask
      ask
    end

    def delete_bid(bid)
      @tree[:bid].delete bid
      bid
    end

    def depth(size=10)
      { asks: @tree[:ask].keys[0,size].map {|o| depth_format(o) },
        bids: @tree[:bid].keys[0,size].map {|o| depth_format(o) } }
    end

    private

    def depth_format(order)
      "$#{order.price.to_s('F')}/#{order.volume.to_s('F')}"
    end

  end
end
