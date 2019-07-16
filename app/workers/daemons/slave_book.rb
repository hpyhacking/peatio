# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class SlaveBook < Base

      self.sleep_time = 1

      def process
        Market.enabled.each do |market|
          cache_book(market.id)
        end
      end

      def cache_book(market_id)
        Rails.cache.write "peatio:#{market_id}:depth:asks", get_depth(market_id, :ask)
        Rails.cache.write "peatio:#{market_id}:depth:bids", get_depth(market_id, :bid)
        logger.warn message: "SlaveBook (#{market_id}) updated"
      end

      def get_depth(market_id, side)
        Order.where(market_id: market_id, state: 'wait', type: "Order#{side}", ord_type: 'limit')
            .group(:price)
            .sum(:volume)
            .to_a
            .tap { |o| o.reverse! if side == :bid }
      end
    end
  end
end
