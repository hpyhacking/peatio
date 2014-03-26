window.MarketTradesUI = flight.component ->
  @defaultAttrs
    wrap: '.wrap'
    table: 'tbody'
    defaultHeight: 156

  @refresh = (data) ->
    $table = @select('table')
    $table.prepend(JST['market_trade'](trade)) for trade in data.trades

  @after 'initialize', ->
    @on document, 'market::trades', (event, data) => @refresh(data)
    @refresh {trades: _.first(gon.trades, 20).reverse()}
