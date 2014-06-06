module Worker
  class PusherMarket

    def process(payload, metadata, delivery_info)
      trade = Trade.new payload

      trade.ask.member.notify 'trade', trade.for_notify('ask')
      trade.bid.member.notify 'trade', trade.for_notify('bid')

      Global.new(metadata.headers['market']).trigger_trades([trade.for_global])
    end

  end
end
