window.GlobalData = flight.component ->
  @after 'initialize', ->
    @attr.channel = @attr.pusher.subscribe("market-#{gon.market.id}-global")

    @attr.channel.bind 'update', (data) =>
      gon.asks = data.asks
      gon.bids = data.bids
      gon.ticker = data.ticker

      @trigger 'market::ticker', data.ticker
      @trigger 'market::orders', {asks: data.asks, bids: data.bids}

    @attr.channel.bind 'trades', (data) =>
      @trigger 'market::trades', {trades: data.trades}

    # Initializing at bootstrap
    @trigger 'market::ticker', gon.ticker
