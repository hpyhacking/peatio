window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @refresh = (event, data) ->
    $table = @select('table').empty()
    $table.prepend(JST['market_switch'](ticker)) for ticker in data.tickers

  @after 'initialize', ->
    @on document, 'market::tickers', @refresh
