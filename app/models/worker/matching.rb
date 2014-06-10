module Worker
  class Matching

    def initialize
      @loaded_to = {}
      Market.all.each do |market|
        create_engine market
        load_orders market
      end
    end

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      case payload[:action]
      when 'submit'
        submit build_order(payload[:order])
      when 'cancel'
        cancel build_order(payload[:order])
      when 'reload'
        reload payload[:market]
      else
        Rails.logger.fatal "Unknown action: #{payload[:action]}"
      end
    end

    def submit(order)
      return unless order
      engines[order.market.id].submit(order)
    end

    def cancel(order)
      return unless order
      engines[order.market.id].cancel(order)
    end

    def reload(market)
      if market == 'all'
        @engines = {}
        Rails.logger.info "All engines reloaded."
      else
        engines.delete market
        Rails.logger.info "#{market} engine reloaded."
      end
    end

    def build_order(attrs)
      order = ::Matching::OrderBookManager.build_order attrs
      if already_loaded?(order)
        Rails.logger.info "Order##{order.id} already loaded."
        nil
      else
        order
      end
    end

    def already_loaded?(order)
      return false unless @loaded_to[order.market.id]
      order.id <= @loaded_to[order.market.id]
    end

    def create_engine(market)
      engines[market.id] = ::Matching::Engine.new(market)
    end

    def load_orders(market)
      orders = ::Order.active.with_currency(market.id).order('id asc')

      orders.each do |order|
        order = ::Matching::OrderBookManager.build_order order.to_matching_attributes
        engines[market.id].submit order
      end

      @loaded_to[market.id] = orders.last.try(:id)
    end

    def engines
      @engines ||= {}
    end

    # dump limit orderbook
    def on_usr1
      engines.each do |id, eng|
        dump_file = File.join('/', 'tmp', "limit_orderbook_#{id}")
        limit_orders = eng.limit_orders

        File.open(dump_file, 'w') do |f|
          f.puts "ASK"
          limit_orders[:ask].keys.reverse.each do |k|
            f.puts k.to_s('F')
            limit_orders[:ask][k].each {|o| f.puts "\t#{o.label}" }
          end
          f.puts "-"*40
          limit_orders[:bid].keys.reverse.each do |k|
            f.puts k.to_s('F')
            limit_orders[:bid][k].each {|o| f.puts "\t#{o.label}" }
          end
          f.puts "BID"
        end

        puts "#{id} limit orderbook dumped to #{dump_file}."
      end
    end

    # dump market orderbook
    def on_usr2
      engines.each do |id, eng|
        dump_file = File.join('/', 'tmp', "market_orderbook_#{id}")
        market_orders = eng.market_orders

        File.open(dump_file, 'w') do |f|
          f.puts "ASK"
          market_orders[:ask].each {|o| f.puts "\t#{o.label}" }
          f.puts "-"*40
          market_orders[:bid].each {|o| f.puts "\t#{o.label}" }
          f.puts "BID"
        end

        puts "#{id} market orderbook dumped to #{dump_file}."
      end
    end

  end
end
