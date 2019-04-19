# frozen_string_literal: true

module Bench
  module Injectors
    class Bitfinex < Base

      def initialize(config)
        super
        if config[:data_load_path].present?
          @data = YAML.load_file(Rails.root.join(config[:data_load_path]))
          @index = 0
        end
      end

      private

      def construct_order
        @index = 0 if @data[@index].blank?
        order_data = @data[@index]
        price = order_data[1]
        amount = order_data[2]
        market = @markets.sample
        type = amount > 0 ? 'OrderBid' : 'OrderAsk'
        @index += 1
        { type:       type,
          state:      Order::WAIT,
          member:     @members.sample,
          market:     market,
          ask:        market.base_unit,
          bid:        market.quote_unit,
          ord_type:   :limit,
          price:      price,
          volume:     amount.abs }
      end
    end
  end
end
