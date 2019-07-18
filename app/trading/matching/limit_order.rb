# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class LimitOrder < BaseOrder

    attr_reader :price

    def initialize(attrs)
      super
      @price = attrs[:price].to_d

      raise OrderError.new(self, 'Order is not valid') unless valid?(attrs)
    end

    def trade_with(counter_order, _counter_book)
      if counter_order.is_a?(MarketOrder)
        raise MarketOrderbookError.new(order, 'market order in orderbook detected')
      end

      return unless crossed?(counter_order.price)

      trade_price  = counter_order.price
      trade_volume = [volume, counter_order.volume].min
      trade_funds  = trade_price * trade_volume
      [trade_price, trade_volume, trade_funds]
    end

    def fill(_trade_price, trade_volume, _trade_funds)
      raise NotEnoughVolume if trade_volume > @volume
      @volume -= trade_volume
    end

    def filled?
      volume <= ZERO
    end

    def crossed?(price)
      if type == :ask
        price >= @price # if people offer price higher or equal than ask limit
      else
        price <= @price # if people offer price lower or equal than bid limit
      end
    end

    def label
      "%d/$%s/%s" % [id, price.to_s('F'), volume.to_s('F')]
    end

    def valid?(_attrs)
      type.in?(%i[ask bid]) && \
        id.present? && \
        timestamp.present? && \
        market.present? && \
        price > ZERO
    end

    def attributes
      { id:        @id,
        timestamp: @timestamp,
        type:      @type,
        volume:    @volume,
        price:     @price,
        market:    @market,
        ord_type: 'limit' }
    end
  end
end
