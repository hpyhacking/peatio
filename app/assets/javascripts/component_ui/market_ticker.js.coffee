window.MarketTickerUI = flight.component ->
  @attributes
    ticker: 'tbody > tr'

  @refresh = (event, ticker) ->
    @select('ticker').empty().prepend(JST['templates/ticker'](ticker))

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
