window.MarketSwitchUI = flight.component ->
  @attributes
    table: 'tbody'

  @refresh = (event, data) ->
    $table = @select('table').empty()
    for ticker in data.tickers
      ticker['current'] = true if (ticker.market == gon.market.id)
      $table.prepend(JST['market_switch'](ticker))

  @toggle = ->
    $('#market_switch_tabs_wrapper').toggleClass('hover')
    $('#market_switch_tabs_wrapper a:first').tab('show')

  @after 'initialize', ->
    @on document, 'market::tickers', @refresh
    @on document, 'switch-market', @toggle

    @select('table').on 'click', 'tr', (e) ->
      win = window.open("/markets/#{$(@).data('market')}", '_blank')
      win.focus()
