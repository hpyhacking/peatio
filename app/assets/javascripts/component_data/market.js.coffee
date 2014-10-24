@MarketData = flight.component ->
  @refresh = (event, data) ->
    @reqK(data['market'], data['minutes'])

  @reqK = (market = gon.market.id, minutes = 60, limit = 5000) ->
    url = "/api/v2/k.json?market=#{market}&limit=#{limit}&period=#{minutes}"
    $.getJSON url, (data) =>
      @handleData(data, minutes)

  @checkTrend = (pre, cur) ->
    # time, open, high, low, close, volume
    [_, _, _, _, cur_close, _] = cur
    [_, _, _, _, pre_close, _] = pre
    cur_close >= pre_close # {true: up, false: down}

  @computeMA = (old, sum, unit) ->
    # time, open, high, low, close, volume
    [_, _, _, _, old_close, _] = old
    [sum / unit, sum - old_close]

  @handleData = (data, minutes) ->
    ma = [[], [], [], []]
    ma_sum = [0, 0, 0, 0]
    ma_def = [4, 9, 14, 29]
    [volume, candlestick] = [[], []]

    for cur, i in data
      [time, open, high, low, close, vol] = cur
      time = time * 1000 # fixed unix timestamp for highsotck
      trend = if i >= 1 then @checkTrend(data[i-1], cur) else true

      # compute MA
      #===========================================
      ma_sum[k] = s + close for s, k in ma_sum

      for x, j in ma_def
        continue if i < x
        unit = x + 1
        old = data[i-x]
        sum = ma_sum[j]

        [ma_val, new_sum] = @computeMA(old, sum, unit)
        ma[j].push [time, ma_val]
        ma_sum[j] = new_sum

      candlestick.push [time, open, high, low, close]
      volume.push {x: time, y: vol, color: if trend then 'rgba(255, 0, 0, 0.5)' else 'rgba(0, 255, 0, 0.5)'}

    result = candlestick: candlestick, volume: volume, orig: data, minutes: minutes
    result["ma#{x + 1}"] = ma[q] for x, q in ma_def

    @trigger 'market::candlestick::response', result

  @after 'initialize', ->
    @on document, 'market::candlestick::request', @refresh
