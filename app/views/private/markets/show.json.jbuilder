json.ask @ask
json.bid @bid
json.asks @asks
json.bids @bids
json.trades @trades
json.ticker @ticker

json.i18n do
  json.brand I18n.t('gon.brand')
  json.ask I18n.t('gon.ask')
  json.bid I18n.t('gon.bid')
  json.cancel I18n.t('actions.cancel')
  json.chart_price I18n.t('chart.price')
  json.chart_volume I18n.t('chart.volume')
  json.place_order do |place_order|
    place_order.confirm_submit I18n.t('private.markets.show.confirm')
    place_order.price I18n.t('private.markets.place_order.price')
    place_order.volume I18n.t('private.markets.place_order.amount')
    place_order.sum I18n.t('private.markets.place_order.total')
    place_order.price_high I18n.t('private.markets.place_order.price_high')
    place_order.price_low I18n.t('private.markets.place_order.price_low')
  end
end

json.accounts do
  json.set! @ask, 'ask'
  json.set! @bid, 'bid'
  json.ask do json.(@member.get_account(@ask), :balance, :locked, :currency) end
  json.bid do json.(@member.get_account(@bid), :balance, :locked, :currency) end
end

json.orders do
  json.wait *([@orders_wait] + Order::ATTRIBUTES)
  json.done @trades_done.reverse.map {|t| t.for_notify }
  json.cancel *([@orders_cancel] + Order::ATTRIBUTES)
end
