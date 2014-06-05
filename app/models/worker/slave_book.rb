module Worker
  class SlaveBook

    def initialize
      @ask_orderbook = ::Matching::OrderBook.new(:ask, broadcast: false)
      @bid_orderbook = ::Matching::OrderBook.new(:bid, broadcast: false)
    end

    def process(payload, metadata, delivery_info)
      order = build_order payload['order']
      book, counter_book = get_books order.type

      case payload['action']
      when 'add'
        book.add order
      when 'remove'
        book.remove order
      else
        raise ArgumentError, "Unknown action: #{payload['action']}"
      end
    end

    def build_order(attrs)
      attrs.symbolize_keys!
      klass = ::Matching.const_get "#{attrs[:ord_type]}_order".camelize
      klass.new attrs
    end

    def get_books(type)
      case type
      when :ask
        [@ask_orderbook, @bid_orderbook]
      when :bid
        [@bid_orderbook, @ask_orderbook]
      end
    end

  end
end
