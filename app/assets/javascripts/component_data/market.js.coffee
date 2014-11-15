@MarketData = flight.component ->

  @load = (event, data) ->
    @trigger 'market::candlestick::request'
    @reqK gon.market.id, gon.trades[gon.trades.length-1], data['x']

  @reqK = (market, trade, minutes, limit = 5000) ->
    url = "/api/v2/k_with_pending_trades.json?market=#{market}&limit=#{limit}&period=#{minutes}&trade_id=#{trade.tid}"
    $.getJSON url, (data) =>
      @handleData(data, minutes)

  @checkTrend = (pre, cur) ->
    # time, open, high, low, close, volume
    [_, _, _, _, cur_close, _] = cur
    [_, _, _, _, pre_close, _] = pre
    cur_close >= pre_close # {true: up, false: down}

  @prepare = (k, minutes) ->
    [volume, candlestick, close_price] = [[], [], []]

    for cur, i in k
      [time, open, high, low, close, vol] = cur
      time = time * 1000 # fixed unix timestamp for highsotck
      trend = if i >= 1 then @checkTrend(k[i-1], cur) else true

      close_price.push [time, close]
      candlestick.push [time, open, high, low, close]
      volume.push {x: time, y: vol, color: if trend then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'}

    candlestick: candlestick, volume: volume, orig: k, minutes: minutes, close: close_price

  @create = (result, time, trade) ->
    p = parseFloat(trade.price)
    result.candlestick.push [time, p, p, p, p]

  @updatePoint = (ohlc, trade) ->
    p = parseFloat(trade.price)

    if p > ohlc[2]
      ohlc[2] = p
    else if p < ohlc[3]
      ohlc[3] = p
    ohlc[4] = p

  @patch = (result, trades, minutes) ->
    $.each trades, (i, trade) =>
      last = result.candlestick[result.candlestick.length-1]
      last_ts = last[0]
      next_ts = last[0] + minutes*60*1000

      ts = trade.date * 1000
      if last_ts <= ts && ts < next_ts
        @updatePoint last, trade
      else if ts >= next_ts
        @createPoint result, next_ts, trade

  @handleData = (data, minutes) ->
    {k: k, trades: trades} = data

    result = @prepare k, minutes
    @patch result, trades, minutes

    @trigger 'market::candlestick::response', result

  @after 'initialize', ->
    @on document, 'switch::range_switch', @load
