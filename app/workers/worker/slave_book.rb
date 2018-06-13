# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class SlaveBook

    def initialize(run_cache_thread=true)
      @managers = {}

      if run_cache_thread
        cache_thread = Thread.new do
          loop do
            sleep 3
            cache_book
          end
        end
      end
    end

    def process(payload, metadata, delivery_info)
      @payload = Hashie::Mash.new payload

      case @payload.action
      when 'new'
        @managers.delete(@payload.market)
        initialize_orderbook_manager(@payload.market)
      when 'add'
        book.add order
      when 'update'
        book.find(order).volume = order.volume # only volume would change
      when 'remove'
        book.remove order
      else
        raise ArgumentError, "Unknown action: #{@payload.action}"
      end
    rescue
      Rails.logger.error { "Failed to process payload: #{$!}" }
      Rails.logger.error { $!.backtrace.join("\n") }
    end

    def cache_book
      @managers.keys.each do |market_id|
        Rails.cache.write "peatio:#{market_id}:depth:asks", get_depth(market_id, :ask)
        Rails.cache.write "peatio:#{market_id}:depth:bids", get_depth(market_id, :bid)
        Rails.logger.debug { "SlaveBook (#{market_id}) updated" }
      end
    rescue
      Rails.logger.error { "Failed to cache book: #{$!}" }
      Rails.logger.error { $!.backtrace.join("\n") }
    end

    def order
      ::Matching::OrderBookManager.build_order @payload.order.to_h
    end

    def book
      manager.get_books(@payload.order.type.to_sym).first
    end

    def manager
      market = @payload.order.market
      @managers[market] || initialize_orderbook_manager(market)
    end

    def initialize_orderbook_manager(market)
      @managers[market] = ::Matching::OrderBookManager.new(market, broadcast: false)
    end

    def get_depth(market, side)
      depth = Hash.new { |h, k| h[k] = 0 }
      @managers[Market === market ? market.id : market].send("#{side}_orders").limit_orders.each do |price, orders|
        depth[price] += orders.map(&:volume).sum
      end

      depth = depth.to_a
      depth.reverse! if side == :bid
      depth
    end

  end
end
