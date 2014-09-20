json.ask @ask
json.bid @bid
json.asks @asks
json.bids @bids
json.trades @trades
json.ticker @ticker

if @member
  json.current_user do
    json.sn @member.sn
  end

  json.accounts do
    json.set! @ask, 'ask'
    json.set! @bid, 'bid'
    json.ask do json.(@member.get_account(@ask), :balance, :locked, :currency) end
    json.bid do json.(@member.get_account(@bid), :balance, :locked, :currency) end
  end

  json.orders do
    json.wait *([@orders_wait] + Order::ATTRIBUTES)
    json.done @trades_done.map {|t|
      if t.self_trade?
        [t.for_notify('ask'), t.for_notify('bid')]
      else
        t.for_notify
      end
    }.flatten
    json.cancel *([@orders_cancel] + Order::ATTRIBUTES)
  end
end
