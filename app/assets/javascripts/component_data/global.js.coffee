window.GlobalData = flight.component ->

  @refreshDocumentTitle = (event, data) ->
    symbol = gon.currencies[gon.market.bid.currency].symbol
    price  = data.last
    market = [gon.market.ask.currency, gon.market.bid.currency].join("/").toUpperCase()
    brand  = "Peatio Exchange"

    document.title = "#{symbol}#{price} #{market} - #{brand}"

  @after 'initialize', ->
    @on document, 'market::ticker', @refreshDocumentTitle

    channel = @attr.pusher.subscribe("market-#{gon.market.id}-global")

    channel.bind 'update', (data) =>
      gon.asks = data.asks
      gon.bids = data.bids
      gon.ticker = data.ticker

      @trigger 'market::ticker', data.ticker
      @trigger 'market::orders', {asks: data.asks, bids: data.bids}

    channel.bind 'trades', (data) =>
      @trigger 'market::trades', {trades: data.trades}

    # Initializing at bootstrap
    @trigger 'market::ticker', gon.ticker
