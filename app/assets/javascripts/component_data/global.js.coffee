window.GlobalData = flight.component ->
  @.after 'initialize', ->
    @.attr.channel = @.attr.pusher.subscribe("market-#{gon.market.id}-global");

    @.attr.channel.bind 'update', (data) =>
      gon.asks = data.asks
      gon.bids = data.bids
      gon.ticker = data.ticker

      @.trigger document, 'pusher::ticker', data.ticker
      @.trigger document, 'pusher::orders', {asks: data.asks, bids: data.bids}

    @.attr.channel.bind 'trades', (data) =>
      @.trigger document, 'pusher::trades', {trades: data.trades}
