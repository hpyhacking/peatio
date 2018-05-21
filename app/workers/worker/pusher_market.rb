# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class PusherMarket

    def process(payload, metadata, delivery_info)
      trade = Trade.new payload
      trade.trigger_notify
      Global[trade.market].trigger_trades [trade.for_global]
    end

  end
end
