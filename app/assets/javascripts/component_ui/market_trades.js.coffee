window.MarketTradesUI = flight.component ->
  @attributes
    wrap: '.wrap'
    table: 'tbody'
    defaultHeight: 156

  @refresh = (event, data) ->
    $table = @select('table')
    $table.prepend(JST['market_trade'](trade)) for trade in data.trades

  @after 'initialize', ->
    @on document, 'market::trades', @refresh
