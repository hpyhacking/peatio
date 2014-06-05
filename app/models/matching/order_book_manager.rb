module Matching
  class OrderBookManager

    attr :ask_orders, :bid_orders

    def self.build_order(attrs)
      attrs.symbolize_keys!
      klass = ::Matching.const_get "#{attrs[:ord_type]}_order".camelize
      klass.new attrs
    end

    def initialize(options={})
      @ask_orders = OrderBook.new(:ask, options)
      @bid_orders = OrderBook.new(:bid, options)
    end

    def get_books(type)
      case type
      when :ask
        [@ask_orders, @bid_orders]
      when :bid
        [@bid_orders, @ask_orders]
      end
    end

  end
end
