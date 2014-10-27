window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @refresh = (event, data) ->
    $table = @select('table').empty()
    for ticker in data.tickers
      ticker['current'] = true if (ticker.market == gon.market.id)
      $table.prepend(JST['market_switch'](ticker))

  @after 'initialize', ->
    @on document, 'market::tickers', @refresh
    @select('table').on 'click', 'tr', (e) ->
      win = window.open("/markets/#{$(@).data('market')}", '_blank')
      win.focus()
