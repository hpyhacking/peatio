window.MarketTickerUI = flight.component ->
  @attributes
    askSelector: '.ask .price'
    bidSelector: '.bid .price'
    lastSelector: '.last .price'

  @refresh = (event, ticker) ->
    @select('askSelector').html(JST['templates/ticker'](trend: ticker.sell_trend, price: ticker.sell))
    @select('bidSelector').html(JST['templates/ticker'](trend: ticker.buy_trend, price: ticker.buy))
    @select('lastSelector').html(JST['templates/ticker'](trend: ticker.last_trend, price: ticker.last))

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh
