@HeaderUI = flight.component ->
  @attributes
    switch: 'a.switch-market'
    market: 'p > span.market'
    vol: 'span.vol'
    amount: 'span.amount'
    high: 'span.high'
    low: 'span.low'

  @refresh = (event, ticker) ->
    @select('vol').text("#{ticker.volume} #{gon.market.base_unit.toUpperCase()}")
    @select('high').text(ticker.high)
    @select('low').text(ticker.low)

  @after 'initialize', ->
    @select('market').text("#{gon.market.base_unit.toUpperCase()}/#{gon.market.quote_unit.toUpperCase()}")

    @on @select('switch'), 'click', ->
      @trigger 'switch-market'

    @on document, 'market::ticker', @refresh

