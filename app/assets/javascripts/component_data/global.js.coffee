window.GlobalData = flight.component ->
  @after 'initialize', ->
    channel = @attr.pusher.subscribe("market-#{gon.market.id}-global")

    channel.bind 'update', (data) =>
      gon.asks = data.asks
      gon.bids = data.bids
      gon.ticker = data.ticker

      @trigger 'market::ticker', data.ticker
      @trigger 'market::orders', {asks: data.asks, bids: data.bids}

    channel.bind 'trades', (data) =>
      @trigger 'market::trades', {trades: data.trades}
