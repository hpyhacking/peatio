json.asks @asks
json.bids @bids
json.trades @trades

if @member
  json.my_trades @trades_done.map(&:for_notify)
  json.my_orders *([@orders_wait] + %i[id at market kind price state volume origin_volume])
end
