# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class PusherMarket
    def process(payload)
      trade = Trade.new(payload)
      Pusher["private-#{trade.ask.member.sn}"].trigger(:trade, trade.for_notify('ask'))
      Pusher["private-#{trade.bid.member.sn}"].trigger(:trade, trade.for_notify('bid'))
      Pusher["market-#{trade.market.id}-global"].trigger(:trades, trades: [trade.for_global])
    end
  end
end
