window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @refresh = (event, data) ->
    $table = @select('table').empty()
    $table.prepend(JST['market_switch'](ticker)) for ticker in data.tickers

  @open = ->
    $('#market_switch_tabs_wrapper').addClass('hover')
    $('#market_switch_tabs_wrapper a:first').tab('show')

  @after 'initialize', ->
    @on document, 'market::tickers', @refresh
    @on document, 'switch-market', @open
