window.MarketTradesUI = flight.component ->
  @attributes
    wrap: '.wrap'
    defaultHeight: 156
    tableSelector: 'tbody'
    newTradeSelector: 'tr.new'
    newTradeContentSelector: 'tr.new div'

  @clearMarkers = ->
    @select('newTradeSelector').removeClass('new')

  @refresh = (event, data) ->
    table = @select('tableSelector')
    for trade in data.trades
      trade.classes = 'new'
      el = table.prepend(JST['templates/market_trade'](trade))

    @select('newTradeContentSelector').slideDown('slow')
    setTimeout =>
      @clearMarkers()
    , 900

  @after 'initialize', ->
    @on document, 'market::trades', @refresh
