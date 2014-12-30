window.MarketTradesUI = flight.component ->
  flight.compose.mixin @, [NotificationMixin]

  @attributes
    defaultHeight: 156
    tradeSelector: 'tr'
    newTradeSelector: 'tr.new'
    allSelector: 'a.all'
    mySelector: 'a.my'
    allTableSelector: 'table.all-trades tbody'
    myTableSelector: 'table.my-trades tbody'
    newMarketTradeContent: 'table.all-trades tr.new div'
    newMyTradeContent: 'table.my-trades tr.new div'
    tradesLimit: 80

  @showAllTrades = (event) ->
    @select('mySelector').removeClass('active')
    @select('allSelector').addClass('active')
    @select('myTableSelector').hide()
    @select('allTableSelector').show()

  @showMyTrades = (event) ->
    @select('allSelector').removeClass('active')
    @select('mySelector').addClass('active')
    @select('allTableSelector').hide()
    @select('myTableSelector').show()

  @bufferMarketTrades = (event, data) ->
    @marketTrades = @marketTrades.concat data.trades

  @clearMarkers = (table) ->
    table.find('tr.new').removeClass('new')
    table.find('tr').slice(@attr.tradesLimit).remove()

  @notifyMyTrade = (trade) ->
    message = gon.i18n.notification.new_trade
      .replace(/%{kind}/g, gon.i18n[trade.kind])
      .replace(/%{id}/g, trade.id)
      .replace(/%{price}/g, trade.price)
      .replace(/%{volume}/g, trade.volume)
      .replace(/%{base_unit}/g, gon.market.base_unit.toUpperCase())
      .replace(/%{quote_unit}/g, gon.market.quote_unit.toUpperCase())
    @notify message

  @isMine = (trade) ->
    if @myTrades.length == 0 || trade.tid > @myTrades[0].id
      false
    else
      !!(_.find @myTrades, (t) -> t.id == trade.tid)

  @handleMarketTrades = (event, data) ->
    for trade in data.trades
      @marketTrades.unshift trade
      trade.classes = 'new'
      trade.isMine = @isMine(trade)
      el = @select('allTableSelector').prepend(JST['templates/market_trade'](trade))

    @marketTrades = @marketTrades.slice(0, @attr.tradesLimit)
    @select('newMarketTradeContent').slideDown('slow')

    setTimeout =>
      @clearMarkers(@select('allTableSelector'))
    , 900

  @handleMyTrades = (event, data) ->
    for trade in data.trades
      @myTrades.unshift trade
      trade.classes = 'new'
      el = @select('myTableSelector').prepend(JST['templates/my_trade'](trade))
      @notifyMyTrade(trade)

    @myTrades = @myTrades.slice(0, @attr.tradesLimit) if @myTrades.length > @attr.tradesLimit
    @select('newMyTradeContent').slideDown('slow')

    setTimeout =>
      @clearMarkers(@select('myTableSelector'))
    , 900

  @init = (event, data) ->
    @handleMyTrades(event, trades: data.trades.reverse())

    data = trades: @marketTrades
    @marketTrades = []
    @handleMarketTrades(event, data)

    @on document, 'market::trades', @handleMarketTrades

  @after 'initialize', ->
    @marketTrades = []
    @myTrades = []

    @on document, 'market::trades', @bufferMarketTrades

    @on document, 'trade::populate', @init
    @on document, 'trade', (event, trade) =>
      @handleMyTrades(event, trades: [trade])

    @on @select('allSelector'), 'click', @showAllTrades
    @on @select('mySelector'), 'click', @showMyTrades
