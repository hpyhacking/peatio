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
      gon.tickers[gon.market.id] = data.ticker

      @trigger 'market::ticker',  gon.ticker
      @trigger 'market::order_book', asks: gon.asks, bids: gon.bids

    channel.bind 'trades', (data) =>
      @trigger 'market::trades', {trades: data.trades}

    # Initializing at bootstrap
    @trigger 'market::trades', {trades: gon.trades}
    @trigger 'market::ticker', gon.ticker
