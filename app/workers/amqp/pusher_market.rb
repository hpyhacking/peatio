# encoding: UTF-8
# frozen_string_literal: true

require "peatio/ranger/events"

module Workers
  module AMQP
    class PusherMarket < Base
      def process(payload)
        trade = Trade.new(payload)

        Peatio::Ranger::Events.publish("private", trade.maker.uid, "trade", trade.for_notify(trade.maker))
        Peatio::Ranger::Events.publish("private", trade.taker.uid, "trade", trade.for_notify(trade.taker))
        Peatio::Ranger::Events.publish("public", trade.market.id, "trades", {trades: [trade.for_global]})
      end
    end
  end
end
