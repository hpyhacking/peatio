window.MarketTradesUI = flight.component ->
  @attributes
    wrap: '.wrap'
    defaultHeight: 156
    tableSelector: 'tbody'
    tradeSelector: 'tr'
    newTradeSelector: 'tr.new'
    newTradeContentSelector: 'tr.new div'
    tradesLimit: 80

  @clearMarkers = ->
    @select('newTradeSelector').removeClass('new')
    @select('tradeSelector').slice(@attr.tradesLimit).remove()

  @isMine = (trade) ->
    if @myTrades.length == 0 || trade.tid > @myTrades[0].id
      false
    else
      !!(_.find @myTrades, (t) -> t.id == trade.tid)

  @refresh = (event, data) ->
    table = @select('tableSelector')
    for trade in data.trades
      trade.classes = 'new'
      trade.isMine = @isMine(trade)
      el = table.prepend(JST['templates/market_trade'](trade))

    @select('newTradeContentSelector').slideDown('slow')
    setTimeout =>
      @clearMarkers()
    , 900

  @prependMyTrade = (event, trade) ->
    exist = _.find @myTrades, (t) -> t.id == trade.id
    unless exist
      @myTrades.unshift trade
      @myTrades = @myTrades.slice(0, @attr.tradesLimit) if @myTrades.length > @attr.tradesLimit

  @populateMyTrades = (event, data) ->
    @myTrades = data.trades
    @refresh(event, trades: @marketTrades)
    @on document, 'market::trades', @refresh

  @bufferMarketTrades = (event, data) ->
    @marketTrades = @marketTrades.concat data.trades

  @after 'initialize', ->
    @marketTrades = []
    @on document, 'market::trades', @bufferMarketTrades

    @on document, 'trade::populate', @populateMyTrades
    @on document, 'trade', @prependMyTrade
