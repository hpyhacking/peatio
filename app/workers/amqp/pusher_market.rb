# encoding: UTF-8
# frozen_string_literal: true

require "peatio/mq/events"

module Workers
  module AMQP
    class PusherMarket < Base
      def process(payload)
        trade = Trade.new(payload)

        Peatio::MQ::Events.publish("private", trade.maker.uid, "trade", trade.for_notify(trade.maker))
        Peatio::MQ::Events.publish("private", trade.taker.uid, "trade", trade.for_notify(trade.taker))
        Peatio::MQ::Events.publish("public", trade.market.id, "trades", {trades: [trade.for_global]})
      end
    end
  end
end
