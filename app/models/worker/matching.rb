module Worker
  class Matching

    def process(payload, metadata, delivery_info)
      @payload = payload.symbolize_keys
      send @payload[:action]
    end

    def submit
      @order = ::Matching::Order.new @payload[:order]
      engine.submit @order
    end

    def cancel
      @order = ::Matching::Order.new @payload[:order]
      engine.cancel @order
    end

    def reload
      if @payload[:market] == 'all'
        @engines = {}
        Rails.logger.info "All engines reloaded."
      else
        engines.delete @payload[:market]
        Rails.logger.info "#{@payload[:market]} engine reloaded."
      end
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
        order = ::Matching::Order.new order.to_matching_attributes
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

  end
end
