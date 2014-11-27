@MarketData = flight.component ->

  @load = (event, data) ->
    @trigger 'market::candlestick::request'
    @reqK gon.market.id, gon.trades[gon.trades.length-1], data['x']

  @reqK = (market, trade, minutes, limit = 4200) ->
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

    candlestick: candlestick, volume: volume, close: close_price, orig: k, minutes: minutes

  @createPoint = (result, time, trade) ->
    p = parseFloat(trade.price)
    v = parseFloat(trade.amount)

    result.close.push [time, p]
    result.candlestick.push [time, p, p, p, p]
    result.volume.push {x: time, y: v, color: if p >= result.close[result.close.length-2][1] then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'}

  @updatePoint = (result, i, trade) ->
    p = parseFloat(trade.price)
    v = parseFloat(trade.amount)

    result.close[i][1] = p

    if p > result.candlestick[i][2]
      result.candlestick[i][2] = p
    else if p < result.candlestick[i][3]
      result.candlestick[i][3] = p
    result.candlestick[i][4] = p

    result.volume[i]['y'] += v
    result.volume[i]['color'] = if i > 0 && result.close[i][1] >= result.close[i-1][1] then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'

  @patch = (result, trades, minutes) ->
    $.each trades, (ti, trade) =>
      i = result.candlestick.length - 1
      last = result.candlestick[i]
      last_ts = last[0]
      next_ts = last[0] + minutes*60*1000

      ts = trade.date * 1000
      if last_ts <= ts && ts < next_ts
        result.volume[i]['y'] = 0 if ti == 0 # prevent double calculate volume
        @updatePoint result, i, trade
      else if ts >= next_ts
        @createPoint result, next_ts, trade

  @handleData = (data, minutes) ->
    {k: k, trades: trades} = data

    result = @prepare k, minutes

    if trades.length > 0
      @patch result, trades, minutes
      offset = trades[trades.length-1].tid - @tradesCache[0].tid + 1
      @tradesCache = @tradesCache.slice(offset) if offset > 0

    @trigger 'market::candlestick::response', result

  @deliverTrades = (event, data) ->
    minutes = data.minutes
    @trigger 'market::candlestick::update', trades: @tradesCache, minutes: minutes

    # FIXME:
    #
    # It's possible a few trades will be missed, which caused by a problem in
    # GlobalData compoenent, not here.
    #
    # The first batch of trades come from gon in html, then GlobalData just
    # forwards all trades received from pusher. Trades created after page
    # rendered on server but before trades channel connected will lost.
    #
    # Since the delay is small, user barely notice this in most cases.
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
