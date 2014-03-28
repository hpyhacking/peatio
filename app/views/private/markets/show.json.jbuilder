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
end

json.accounts do
  json.set! @ask, 'ask'
  json.set! @bid, 'bid'
  json.ask do json.(@member.get_account(@ask), :balance, :locked, :currency) end
  json.bid do json.(@member.get_account(@bid), :balance, :locked, :currency) end
end

json.orders do
  json.wait *([@orders_wait] + Order::ATTRIBUTES)
  json.done *([@orders_done] + Order::ATTRIBUTES)
  json.cancel *([@orders_cancel] + Order::ATTRIBUTES)
end
