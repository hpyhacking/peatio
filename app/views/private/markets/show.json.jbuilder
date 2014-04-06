json.ask @ask
json.bid @bid
json.asks @asks
json.bids @bids
json.trades @trades
json.market @market.attributes
json.market_config @market.attributes

json.i18n do
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
  json.done @trades_done
  json.cancel *([@orders_cancel] + Order::ATTRIBUTES)
end
