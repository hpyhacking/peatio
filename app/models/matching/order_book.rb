module Matching
  class OrderBook

    def initialize
      @tree = {ask: RBTree.new, bid: RBTree.new}
    end

    def submit(order)
      @tree[order.type][order] = true
      @lowest_ask = @highest_bid = nil
      order
    end

    def lowest_ask
      @lowest_ask ||= @tree[:ask].first[0]
    end

    def highest_bid
      @highest_bid ||= @tree[:bid].last[0]
    end

    def matchable?
      !@tree[:ask].empty? && !@tree[:bid].empty?
    end

    def pop_closest_pair!
      [delete_ask(lowest_ask), delete_bid(highest_bid)]
    end

    def delete_ask(ask)
      @tree[:ask].delete ask
      @lowest_ask = nil
      ask
    end

    def delete_bid(bid)
      @tree[:bid].delete bid
      @highest_bid = nil
      bid
    end

  end
end
