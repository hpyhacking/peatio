@MarketData = flight.component ->
  @refresh = (event, data) ->
    @reqK(gon.market.id, data['x'])

  @reqK = (market = gon.market.id, minutes = 60, limit = 5000) ->
    url = "/api/v2/k.json?market=#{market}&limit=#{limit}&period=#{minutes}"
    $.getJSON url, (data) =>
      @handleData(data, minutes)

  @checkTrend = (pre, cur) ->
    # time, open, high, low, close, volume
    [_, _, _, _, cur_close, _] = cur
    [_, _, _, _, pre_close, _] = pre
    cur_close >= pre_close # {true: up, false: down}

  @handleData = (data, minutes) ->
    [volume, candlestick, close_price] = [[], [], []]

    for cur, i in data
      [time, open, high, low, close, vol] = cur
      time = time * 1000 # fixed unix timestamp for highsotck
      trend = if i >= 1 then @checkTrend(data[i-1], cur) else true

      close_price.push [time, close]
      candlestick.push [time, open, high, low, close]
      volume.push {x: time, y: vol, color: if trend then 'rgba(255, 0, 0, 0.5)' else 'rgba(0, 255, 0, 0.5)'}

    result = candlestick: candlestick, volume: volume, orig: data, minutes: minutes, close: close_price

    @trigger 'market::candlestick::response', result

  @after 'initialize', ->
    @on document, 'switch::range_switch', @refresh
