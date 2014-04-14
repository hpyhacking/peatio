module Worker
  class Matching

    def process(payload)
      payload.symbolize_keys!
      @order = ::Matching::Order.new payload[:order]
      send payload[:action]
    end

    def submit
      engine.submit!(@order)
    end

    def cancel
      engine.cancel!(@order)
    end

    def engine
      engines[@order.market.id] ||= create_engine
    end

    def create_engine
      engine = ::Matching::FIFOEngine.new(@order.market)
      load_orders(engine) unless ENV['FRESH'] == '1'
      engine
    end

    def load_orders(engine)
      orders = ::Order.active.with_currency(@order.market.id)
        .where('id != ?', @order.id).order('id asc')

      orders.each do |order|
        order = ::Matching::Order.new order.to_matching_attributes
        engine.submit! order
      end
    end

    def engines
      @engines ||= {}
    end

  end
end
