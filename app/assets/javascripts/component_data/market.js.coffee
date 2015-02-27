@MarketData = flight.component ->

  @load = (event, data) ->
    @trigger 'market::candlestick::request'
    @reqK gon.market.id, data['x']

  @reqK = (market, minutes, limit = 768) ->
    tid = if gon.trades.length > 0 then gon.trades[0].tid else 0
    tid = @last_tid+1 if @last_tid
    url = "/api/v2/k_with_pending_trades.json?market=#{market}&limit=#{limit}&period=#{minutes}&trade_id=#{tid}"
    $.getJSON url, (data) =>
      @handleData(data, minutes)

  @checkTrend = (pre, cur) ->
    # time, open, high, low, close, volume
    [_, _, _, _, cur_close, _] = cur
    [_, _, _, _, pre_close, _] = pre
    cur_close >= pre_close # {true: up, false: down}

  @createPoint = (i, trade) ->
    # if the gap between old and new point is too wide (> 100 points), stop live
    # load and show hints
    gap = Math.floor((trade.date-@next_ts) / (@minutes*60))
    if gap > 100
      console.log "failed to update, too wide gap."
      window.clearInterval @interval
      @trigger 'market::candlestick::request'
      return i

    while trade.date >= @next_ts
      x = @next_ts*1000

      @last_ts = @next_ts
      @next_ts = @last_ts + @minutes*60

      [p, v] = if trade.date < @next_ts
                 [parseFloat(trade.price), parseFloat(trade.amount)]
               else
                 [@points.close[i][1], 0]

      @points.close.push [x, p]
      @points.candlestick.push [x, p, p, p, p]
      @points.volume.push {x: x, y: v, color: if p >= @points.close[i][1] then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'}
      i += 1
    i

  @updatePoint = (i, trade) ->
    p     = parseFloat(trade.price)
    v     = parseFloat(trade.amount)

    @points.close[i][1] = p

    if p > @points.candlestick[i][2]
      @points.candlestick[i][2] = p
    else if p < @points.candlestick[i][3]
      @points.candlestick[i][3] = p
    @points.candlestick[i][4] = p

    @points.volume[i].y += v
    @points.volume[i].color = if i > 0 && @points.close[i][1] >= @points.close[i-1][1] then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'

  @refreshUpdatedAt = ->
    @updated_at = Math.round(new Date().valueOf()/1000)

  @processTrades = ->
    i = @points.candlestick.length - 1
    $.each @tradesCache, (ti, trade) =>
      if trade.tid > @last_tid
        if @last_ts <= trade.date && trade.date < @next_ts
          @updatePoint i, trade
        else if @next_ts <= trade.date
          i = @createPoint i, trade
        @last_tid = trade.tid
        @refreshUpdatedAt()
    @tradesCache = []

  @prepare = (k) ->
    [volume, candlestick, close_price] = [[], [], []]

    for cur, i in k
      [time, open, high, low, close, vol] = cur
      time = time * 1000 # fixed unix timestamp for highsotck
      trend = if i >= 1 then @checkTrend(k[i-1], cur) else true

      close_price.push [time, close]
      candlestick.push [time, open, high, low, close]
      volume.push {x: time, y: vol, color: if trend then 'rgba(0, 255, 0, 0.5)' else 'rgba(255, 0, 0, 0.5)'}

    # remove last point from result, because we'll re-calculate it later
    minutes: @minutes, candlestick: candlestick.slice(0, -1), volume: volume.slice(0, -1), close: close_price.slice(0, -1)

  @handleData = (data, minutes) ->
    @minutes = minutes
    @tradesCache = data.trades.concat @tradesCache

    @points   = @prepare data.k
    @last_tid = 0
    if @points.candlestick.length > 0
      @last_ts = @points.candlestick[@points.candlestick.length-1][0]/1000
    else
      @last_ts = 0
    @next_ts = @last_ts + 60*minutes

    @deliverTrades 'market::candlestick::response'

  @deliverTrades = (event) ->
    @processTrades()

    # skip the first point
    @trigger event,
      minutes: @points.minutes
      candlestick: @points.candlestick.slice(1)
      close: @points.close.slice(1)
      volume: @points.volume.slice(1)

    # we only need to keep the last 2 points for future calculation
    @points.close = @points.close.slice(-2)
    @points.candlestick = @points.candlestick.slice(-2)
    @points.volume = @points.volume.slice(-2)

  @hardRefresh = (threshold) ->
    ts = Math.round( new Date().valueOf()/1000 )

    # if there's no trade received in `threshold` seconds, request server side data
    if ts > @updated_at + threshold
      @refreshUpdatedAt()
      @reqK gon.market.id, @minutes

  @startDeliver = (event, data) ->
    if @interval?
      window.clearInterval @interval

    deliver = =>
      if @tradesCache.length > 0
        @deliverTrades 'market::candlestick::trades'
      else
        @hardRefresh(300)

    @interval = setInterval deliver, 999

  @cacheTrades = (event, data) ->
    @tradesCache = Array.prototype.concat @tradesCache, data.trades

  @after 'initialize', ->
    @tradesCache = []
    @on document, 'market::trades', @cacheTrades
    @on document, 'switch::range_switch', @load
    @on document, 'market::candlestick::created', @startDeliver
