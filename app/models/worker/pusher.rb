module Worker
  class Pusher

    def process(payload, metadata, delivery_info)
      case delivery_info[:exchange]
      when AMQPConfig.data[:exchange][:trade_after_strike][:name]
        publish_trade payload
      when AMQPConfig.data[:exchange][:notify_member][:name]
        member = Member.find payload['member_id']
        event  = payload['event']
        data   = JSON.parse payload['data']
        notify_member member, event, data
      end
    end

    def publish_trade(data)
      trade = Trade.find data['id']

      notify_member trade.ask.member, 'trade', trade.for_notify('ask')
      notify_member trade.bid.member, 'trade', trade.for_notify('bid')

      channel = "market-#{data['market']}-global"
      data    = {:trades => [trade.for_global]}
      ::Pusher.trigger_async(channel, "trades", data)
    end

    def notify_member(member, event, data)
      ::Pusher["private-#{member.sn}"].trigger_async event, data
    end

  end
end
