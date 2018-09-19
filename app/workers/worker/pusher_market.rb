# encoding: UTF-8
# frozen_string_literal: true

require "peatio/mq/events"

module Worker
  class PusherMarket
    def process(payload)
      trade = Trade.new(payload)

      Peatio::MQ::Events.publish("private", trade.ask.member.uid, "trade", trade.for_notify("ask"))
      Peatio::MQ::Events.publish("private", trade.bid.member.uid, "trade", trade.for_notify("bid"))
      Peatio::MQ::Events.publish("public", trade.market.id, "trades", {trades: [trade.for_global]})
    end
  end
end
