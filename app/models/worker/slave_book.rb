module Worker
  class SlaveBook

    def initialize
      @orderbook = ::Matching::OrderBookManager.new(broadcast: false)
    end

    def process(payload, metadata, delivery_info)
      order = ::Matching::OrderBookManager.build_order payload['order']
      book, counter_book = @orderbook.get_books order.type

      case payload['action']
      when 'add'
        book.add order
      when 'remove'
        book.remove order
      else
        raise ArgumentError, "Unknown action: #{payload['action']}"
      end
    end

  end
end
