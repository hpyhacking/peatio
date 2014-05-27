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

    def dump
      { asks: @tree[:ask].keys.map {|o| dump_format(o) },
        bids: @tree[:bid].keys.map {|o| dump_format(o) } }
    end

    private

    def dump_format(order)
      "%d/$%.02f/%.04f" % [order.id, order.price, order.volume]
    end

  end
end
