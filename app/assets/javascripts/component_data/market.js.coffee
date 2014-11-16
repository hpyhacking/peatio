@MarketData = flight.component ->

  # FIXME: does the load work on switch?
  @load = (event, data) ->
    @trigger 'market::candlestick::request'
    @reqK gon.market.id, gon.trades[gon.trades.length-1], data['x']

  # FIXME: when limit > 500 live update stop working
  @reqK = (market, trade, minutes, limit = 500) ->
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

  # FIXME: MA, volume need new Point too
  @createPoint = (result, time, trade) ->
    p = parseFloat(trade.price)
    result.candlestick.push [time, p, p, p, p]

  # FIXME: MA, volume need update too
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

  @deliverTrades = (event, data) ->
    minutes = data.minutes
    @trigger 'market::candlestick::update', trades: @tradesCache, minutes: minutes

    @off document, "market::trades"
    @on  document, "market::trades", (event, data) ->
      @trigger 'market::candlestick::update', trades: data.trades, minutes: minutes

  @cacheTrades = (event, data) ->
    @tradesCache = Array.prototype.concat @tradesCache, data.trades

  @after 'initialize', ->
    @tradesCache = []
    @on document, 'market::trades', @cacheTrades
    @on document, 'switch::range_switch', @load
    @on document, 'market::candlestick::created', @deliverTrades
