module Worker
  class Matching

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      @order = build_order payload[:order]
      send payload[:action]
    end

    def submit
      engine.submit @order
    end

    def cancel
      engine.cancel @order
    end

    def engine
      engines[@order.market.id] ||= create_engine
    end

    def create_engine
      engine = ::Matching::Engine.new(@order.market)
      load_orders(engine) unless ENV['FRESH'] == '1'
      engine
    end

    def load_orders(engine)
      orders = ::Order.active.with_currency(@order.market.id)
        .where('id < ?', @order.id).order('id asc')

      orders.each do |order|
        order = ::Matching::LimitOrder.new order.to_matching_attributes
        engine.submit order
      end
    end

    def engines
      @engines ||= {}
    end

    def on_usr1
      engines.each do |id, eng|
        dump_file = File.join('/', 'tmp', "orderbook_dump_#{id}_#{Time.now.to_i}")
        data = eng.dump

        File.open(dump_file, 'w') do |f|
          f.puts "ASK"
          data[:ask_limit_orders].keys.reverse.each do |k|
            f.puts k.to_s('F')
            data[:ask_limit_orders][k].each {|o| f.puts "\t#{o}" }
          end
          f.puts "-"*40
          data[:bid_limit_orders].keys.reverse.each do |k|
            f.puts k.to_s('F')
            data[:bid_limit_orders][k].each {|o| f.puts "\t#{o}" }
          end
          f.puts "BID"
        end

        puts "#{id} orderbook dumped to #{dump_file}."
      end
    end

    def build_order(attrs)
      attrs.symbolize_keys!
      klass = ::Matching.const_get "#{attrs[:ord_type]}_order".camelize
      klass.new attrs
    end

  end
end
